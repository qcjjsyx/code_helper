import unittest
from pathlib import Path

from docgen_sv.parser import parse_verilog


class TestParser(unittest.TestCase):
    def test_parse_sender(self):
        repo_root = Path(__file__).resolve().parents[1]
        path = repo_root / "base" / "sender.v"
        parsed = parse_verilog(path)
        self.assertEqual(parsed.name, "sender")
        self.assertTrue(parsed.ports)

    def test_parse_receiver(self):
        repo_root = Path(__file__).resolve().parents[1]
        path = repo_root / "base" / "receiver.v"
        parsed = parse_verilog(path)
        self.assertEqual(parsed.name, "receiver")
        self.assertTrue(parsed.ports)


if __name__ == "__main__":
    unittest.main()
