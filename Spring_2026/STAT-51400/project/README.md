# LLM DOE Pipeline

A Python project for running a factorial design over LLM-based analyses using a CSV dataset and Ollama as the backend.

## What it does

- Builds summarized artifacts from `data.csv` so the full raw file does not need to be sent to the model on every run.
- Generates a factorial design matrix with randomization and replications.
- Executes each run against Ollama or a `mock` backend.
- Stores prompts, responses, execution times, and token counts reported by Ollama.
- Exports results in a format ready for downstream analysis in a Design of Experiments course project.

## Structure

- `doe.py`: simple CLI entry point.
- `configs/`: ready-to-use experiment configurations.
- `prompts/`: prompt templates.
- `src/llm_doe/`: pipeline logic.
- `artifacts/data/`: derived summaries from the CSV.
- `outputs/`: design matrix, rendered prompts, responses, and metrics.

## Recommended workflow

1. Test the pipeline first without a live Ollama instance:

```bash
python3 doe.py build-data --config configs/pilot_experiment.json
python3 doe.py build-design --config configs/pilot_experiment.json
python3 doe.py run --config configs/pilot_experiment.json
python3 doe.py summarize-results --config configs/pilot_experiment.json
```

2. When you want to use real Ollama models:

```bash
ollama serve
python3 doe.py run --config configs/full_factorial.json --rebuild-data --rebuild-design
```

If you want a fresh run log instead of appending to previous outputs:

```bash
python3 doe.py run --config configs/full_factorial.json --clean
```

## What to edit before running with Ollama

- In `configs/full_factorial.json`, verify the actual tags for the models installed on your machine.
- If your cluster uses different model tags than `qwen3.6:35b`, `llama3:70b`, or `deepseek-r1:70b`, replace them with the correct ones.
- Adjust the number of factor levels if 405 runs are too many for an initial pass.
- Replications are configured to reuse the same treatment combinations three times.

## Included factors

- `model`
- `temperature`
- `prompt_template`
- `data_view`

## Captured output variables

- `wall_clock_seconds`
- `input_token_count`
- `output_token_count`
- `total_token_count`
- `total_duration_seconds`
- `load_duration_seconds`
- `prompt_eval_duration_seconds`
- `eval_duration_seconds`
- JSON validity of the response
- `response_schema_completeness`

## DOE suggestions for the project

- Experimental unit: one LLM analysis run on a fixed view of the dataset.
- Main factors: model, temperature, prompt, and data view.
- Replication: the configs run three replications per treatment combination.
- Possible blocking factor: execution day, machine, or batch if Ollama latency changes over time.
- A natural next factor if you want to enrich the DOE: `num_predict`, `top_p`, or prompt language.

## Tests

```bash
python3 -m unittest discover -s tests
```
