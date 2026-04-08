import unittest
from pathlib import Path

from unused_code.knowledge.indexes.docgen_components.kb import (
    build_entry,
    build_known_components,
    load_known_primitives,
)


class TestComponents(unittest.TestCase):
    def test_parse_arb_merge(self):
        repo_root = Path(__file__).resolve().parents[1]
        path = repo_root / "test_data" / "pipeline" / "cArbMergeN_modName.v"
        known_primitives = load_known_primitives(repo_root)
        known_components = build_known_components()
        entry = build_entry(path, repo_root, known_primitives, known_components)
        self.assertEqual(entry["component_type"], "arb_merge")
        self.assertTrue(entry["deps"]["primitives"])
        self.assertTrue(entry["quality"]["parse_ok"])

    def test_parse_nat_split(self):
        repo_root = Path(__file__).resolve().parents[1]
        path = repo_root / "test_data" / "pipeline" / "cNatSplitN_modName.v"
        known_primitives = load_known_primitives(repo_root)
        known_components = build_known_components()
        entry = build_entry(path, repo_root, known_primitives, known_components)
        self.assertEqual(entry["component_type"], "nat_split")
        self.assertTrue(entry["deps"]["primitives"])
        self.assertTrue(entry["quality"]["parse_ok"])


if __name__ == "__main__":
    unittest.main()
