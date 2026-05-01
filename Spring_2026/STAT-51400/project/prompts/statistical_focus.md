You are running experiment `{{project_name}}`.

Run metadata:
- Run ID: `{{run_id}}`
- Replication: `{{replication}}`
- Factor levels: `{{factor_levels}}`
- Data view: `{{data_view}}`

Primary task:
{{analysis_goal}}

Focus on the statistical analysis plan. Identify the likely response variables, plausible transformations, interaction terms worth testing, model diagnostics, and robustness checks. Do not invent data that are not present in the artifacts.

Use only the supplied artifacts below:

{{data_bundle}}

Return valid JSON only with these keys:
- `research_question`
- `descriptive_findings`
- `response_variables`
- `candidate_model_formula`
- `candidate_interactions`
- `diagnostics`
- `robustness_checks`
- `main_patterns`
- `limitations`
- `next_steps`
