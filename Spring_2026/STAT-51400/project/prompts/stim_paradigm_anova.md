You are running experiment `{{project_name}}`.

Run metadata:
- Run ID: `{{run_id}}`
- Replication: `{{replication}}`
- Factor levels: `{{factor_levels}}`
- Data view: `{{data_view}}`

Primary task:
{{analysis_goal}}

Focus on formal inference by stimulation paradigm using only:
- `Time-to-Target`
- `Success`
- `Path Efficiency`
- `Average Speed`
- `AD`

Interpret `AD` as angular dispersion. Restrict attention to:
- `Combined`
- `ICMS Only`
- `Dim Visual Only`
- `Bright Visual Only`
- `Sham`

Ask for or describe:
- an ANOVA-style comparison strategy for each response variable
- assumptions and diagnostics
- post-hoc analysis when the omnibus result is meaningful

If a response variable makes plain ANOVA inappropriate, say so and name a better alternative.

Use only the supplied artifacts below:

{{data_bundle}}

Return valid JSON only with these keys:
- `research_question`
- `stim_paradigms_compared`
- `response_variables`
- `anova_plan`
- `assumptions_and_diagnostics`
- `posthoc_plan`
- `expected_findings`
- `limitations`
- `recommended_next_analysis`
