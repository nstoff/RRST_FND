#!/usr/bin/env python3
"""
Fit hierarchical DDM using HDDM v0.9.8 to estimate latent decision-making parameters.

This script fits candidate HDDM models to RRST data using Bayesian inference.
It estimates drift rate (v), boundary separation (a), and non-decision time (t),
and compares model fits using Deviance Information Criterion (DIC).

Dependencies:
- hddm==0.9.8
- pandas
- matplotlib
- numpy

Input:
- ddm_data.csv: CSV with columns 'rt', 'response', 'group', 'subj_idx'

Output:
- Saved HDDM model
- Posterior parameter plots
- Model comparison results
"""

import hddm
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

# Load behavioral data
data = pd.read_csv('ddm_data.csv')


# Define candidate models
models = {
    'v': hddm.HDDM(data, depends_on={'v': 'group'}, include=['v', 'a', 't']),
    'a': hddm.HDDM(data, depends_on={'a': 'group'}, include=['v', 'a', 't']),
    't': hddm.HDDM(data, depends_on={'t': 'group'}, include=['v', 'a', 't']),
    'va': hddm.HDDM(data, depends_on={'v': 'group', 'a': 'group'}, include=['v', 'a', 't']),
    'vat': hddm.HDDM(data, depends_on={'v': 'group', 'a': 'group', 't': 'group'}, include=['v', 'a', 't']),
}

# Fit models and collect DICs
dic_scores = {}
for name, m in models.items():
    print(f"\nFitting model: {name}")
    m.find_starting_values()
    m.sample(1000, burn=100)
    dic = m.dic
    dic_scores[name] = dic
    print(f"Model {name} DIC: {dic}")

# Select best model (lowest DIC)
best_model_name = min(dic_scores, key=dic_scores.get)
model = models[best_model_name]
print(f"\nBest model: {best_model_name} (DIC = {dic_scores[best_model_name]:.2f})")

# Save model and summary stats
model.save(f'hddm_model_{best_model_name}')
model.gen_stats().to_csv(f'hddm_model_stats_{best_model_name}.csv')

# Load model
model = hddm.load(f'hddm_model_{best_model_name}')

# Extract drift-rate nodes
v_FND, v_HC = model.nodes_db.node[['v(FND)', 'v(HC)']]

# Plot posterior distributions
hddm.analyze.plot_posterior_nodes([v_FND, v_HC])

# Customize the plot
plt.xlabel('Drift rate')
plt.ylabel('Posterior probability')
plt.title('Posterior of drift-rate group means')

# Save the figure
plt.savefig('drift_rate_posteriors1.pdf')

# Convergence diagnostics
print("\nConvergence diagnostics:")
stats = model.gen_stats()
convergence_flags = []

for param, row in stats.iterrows():
    mc_error = row['mc err']
    std_dev = row['std']
    rel_error = mc_error / std_dev
    if rel_error > 0.1:
        convergence_flags.append((param, rel_error))
        print(f"⚠️ Parameter {param} has MC error > 10% of SD ({rel_error:.2f})")
    else:
        print(f"✓ Parameter {param} converged well (MC error = {rel_error:.2f})")

if not convergence_flags:
    print("\nAll parameters converged adequately.")
else:
    print(f"\n{len(convergence_flags)} parameters may need more samples or model refinement.")
