import unittest
from pathlib import Path

from cc_header_tools.lint import lint_text


class TestCcHeaderTools(unittest.TestCase):
    def test_lint_pass(self):
        path = Path(__file__).resolve().parent / "data" / "good_arb.v"
        text = path.read_text(encoding="utf-8")
        result = lint_text(text, strict=True)
        self.assertTrue(result.ok())

    def test_lint_missing_header(self):
        path = Path(__file__).resolve().parent / "data" / "bad_missing.v"
        text = path.read_text(encoding="utf-8")
        result = lint_text(text, strict=False)
        self.assertFalse(result.ok())


if __name__ == "__main__":
    unittest.main()
