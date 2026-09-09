import json
from pathlib import Path
from typer.testing import CliRunner
from codex_engine.main import app

runner = CliRunner()

def test_regression(tmp_path):
    fixtures_dir = Path(__file__).parent / "fixtures"
    pdf_path = fixtures_dir / "regression.pdf"
    expected_path = fixtures_dir / "regression_expected.json"
    
    assert pdf_path.exists(), "Regression PDF fixture missing"
    assert expected_path.exists(), "Regression expected JSON fixture missing"
    
    output_path = tmp_path / "output.json"
    
    # Run the full pipeline via the CLI entrypoint
    result = runner.invoke(app, [str(pdf_path), "--output", str(output_path)])
    assert result.exit_code == 0, f"Command failed with {result.exit_code}: {result.stdout}"
    
    with open(expected_path, "r", encoding="utf-8") as f:
        expected = json.load(f)
        
    with open(output_path, "r", encoding="utf-8") as f:
        actual = json.load(f)
        
    # Strip runtime-generated UUIDs from blocks before comparison
    for block in expected.get("blocks", []):
        block.pop("id", None)
    for block in actual.get("blocks", []):
        block.pop("id", None)
        
    # Strip block_map as its keys are the random UUIDs
    # (Since block_map is just a dictionary version of blocks, comparing blocks is sufficient)
    expected.pop("block_map", None)
    actual.pop("block_map", None)

    assert actual == expected, "Parsed JSON does not match the expected golden master"
