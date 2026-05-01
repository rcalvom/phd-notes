You are running experiment `{{project_name}}`.

Run metadata:
- Run ID: `{{run_id}}`
- Replication: `{{replication}}`
- Factor levels: `{{factor_levels}}`
- Data view: `{{data_view}}`

Primary task:
{{analysis_goal}}

Focus your answer on how to frame these data as a defensible design-of-experiments study. Be explicit about experimental units, candidate treatment factors from the mouse dataset, possible nuisance variables or blocking factors, and which response variables seem most appropriate.

Use only the supplied artifacts below:

{{data_bundle}}

Return valid JSON only with these keys:
- `research_question`
- `experimental_units`
- `recommended_design`
- `candidate_treatment_factors`
- `candidate_blocking_factors`
- `response_variables`
- `candidate_model_formula`
- `main_patterns`
- `limitations`
- `next_steps`
