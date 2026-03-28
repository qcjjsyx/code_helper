import shutil
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from cc_header_tools.parser import extract_cc_block, parse_yaml_min


def _run(repo_root: Path, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, "-m", "cc_header_tools", *args],
        cwd=repo_root,
        text=True,
        capture_output=True,
        check=False,
    )


def _header(path: Path):
    text = path.read_text(encoding="utf-8", errors="ignore")
    cc_text, _ = extract_cc_block(text)
    assert cc_text, f"missing //@cc header in {path.name}"
    return parse_yaml_min(cc_text)


def test_autogen_infers_family_and_num_ports(tmp_path):
    repo_root = REPO_ROOT
    src_dir = repo_root / "tests" / "data"
    work_dir = tmp_path / "data_copy"
    shutil.copytree(src_dir, work_dir)

    (work_dir / "cPmtFifo_cpu.v").write_text(
        "\n".join(
            [
                "module cPmtFifo_cpu(",
                "    input i_drive,",
                "    input i_freeNext,",
                "    output o_free,",
                "    output o_driveNext,",
                "    output o_fire_1,",
                "    input rst",
                ");",
                "endmodule",
                "",
            ]
        ),
        encoding="utf-8",
    )

    autogen = _run(
        repo_root,
        "strip",
        "--repo",
        ".",
        "--inputs",
        str(work_dir),
        "--inplace",
    )
    assert autogen.returncode == 0, autogen.stderr + autogen.stdout

    autogen = _run(
        repo_root,
        "autogen",
        "--repo",
        ".",
        "--inputs",
        str(work_dir),
        "--inplace",
        "--only-missing",
    )
    assert autogen.returncode == 0, autogen.stderr + autogen.stdout

    lint = _run(repo_root, "lint", "--repo", ".", "--inputs", str(work_dir))
    assert lint.returncode == 0, lint.stderr + lint.stdout

    # 1) SelSplit: NUM_PORTS=2/3/6, and no num_ports_semantics/channels
    for n in (2, 3, 6):
        hdr = _header(work_dir / f"cSelSplit_{n}_{'fetch' if n in (2, 3) else 'exe'}.v")
        assert hdr["family"] == "SelSplit"
        assert hdr["params"]["NUM_PORTS"] == n
        assert "num_ports_semantics" not in hdr["roles"]
        assert "channels" not in hdr["roles"]

    selsplit_hdr = _header(work_dir / "cSelSplit_2_fetch.v")
    assert selsplit_hdr["roles"]["upstream"] == ["i_drive", "o_free"]
    assert selsplit_hdr["roles"]["downstream"] == [
        "o_driveNext0",
        "o_driveNext1",
        "i_freeNext0",
        "i_freeNext1",
    ]

    # 2) MutexMerge/WaitMerge: NUM_PORTS=2/3/4/5/6, and no num_ports_semantics/inputs
    merge_files = [
        ("cWaitMerge_2_d_fetch.v", 2, "WaitMergeN"),
        ("cMutexMerge_3_df_fetch.v", 3, "MutexMergeN"),
        ("cMutexMerge_4_d_fetch.v", 4, "MutexMergeN"),
        ("cMutexMerge_5_df_fetch.v", 5, "MutexMergeN"),
        ("cMutexMerge_6_df_exe.v", 6, "MutexMergeN"),
    ]
    for file_name, n, family in merge_files:
        hdr = _header(work_dir / file_name)
        assert hdr["family"] == family
        assert hdr["params"]["NUM_PORTS"] == n
        assert "num_ports_semantics" not in hdr["roles"]
        assert "inputs" not in hdr["roles"]

    merge_hdr = _header(work_dir / "cMutexMerge_4_d_fetch.v")
    assert merge_hdr["roles"]["upstream"] == [
        "i_drive0",
        "i_drive1",
        "i_drive2",
        "i_drive3",
        "o_free0",
        "o_free1",
        "o_free2",
        "o_free3",
    ]
    assert merge_hdr["roles"]["downstream"] == ["o_driveNext", "i_freeNext"]

    # 3) Fifo1: family=Fifo1 and NUM_PORTS not auto-filled
    fifo_hdr = _header(work_dir / "cFifo1_cpu.v")
    assert fifo_hdr["family"] == "Fifo1"
    assert "NUM_PORTS" not in fifo_hdr["params"]

    # 4) PmtFifo: family=PmtFifo1
    pmt_hdr = _header(work_dir / "cPmtFifo_cpu.v")
    assert pmt_hdr["family"] == "PmtFifo1"


def test_autogen_extracts_data_width_and_fallback_num_ports(tmp_path):
    repo_root = REPO_ROOT
    work_dir = tmp_path / "data_copy"
    work_dir.mkdir(parents=True, exist_ok=True)

    test_file = work_dir / "cArbMerge_custom.v"
    test_file.write_text(
        "\n".join(
            [
                "module cArbMerge_custom #(parameter DATA_WIDTH = 32, parameter NUM_PORTS = 4, parameter PIPE_STAGES = 2) (",
                "    input i_drive0,",
                "    input i_drive1,",
                "    input i_drive2,",
                "    input i_drive3,",
                "    output o_driveNext",
                ");",
                "endmodule",
                "",
            ]
        ),
        encoding="utf-8",
    )

    autogen = _run(
        repo_root,
        "autogen",
        "--repo",
        ".",
        "--inputs",
        str(work_dir),
        "--inplace",
        "--only-missing",
    )
    assert autogen.returncode == 0, autogen.stderr + autogen.stdout

    hdr = _header(test_file)
    assert hdr["params"]["DATA_WIDTH"] == 32
    assert hdr["params"]["NUM_PORTS"] == 4
    assert hdr["params"]["PIPE_STAGES"] == 2
