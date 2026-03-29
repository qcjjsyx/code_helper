import os
import unittest

from verilog_parser.parser import parse_file


class VerilogParserTest(unittest.TestCase):
    def test_cpu_top(self):
        here = os.path.dirname(__file__)
        path = os.path.join(here, "fixtures", "verilog", "cpu_top_easy.v")
        result = parse_file(path)

        self.assertEqual(result.get("top_module_name"), "cpu_top")
        subs = result.get("internal_subnames", [])
        expected = ["Fetch_top", "idu_top", "exe_top", "lsu_top", "mem_slot", "writeBack"]
        for e in expected:
            self.assertIn(e, subs)
        # lsu_top only once
        self.assertEqual(subs.count("lsu_top"), 1)


if __name__ == "__main__":
    unittest.main()
