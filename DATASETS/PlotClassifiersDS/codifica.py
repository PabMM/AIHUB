# %%
import pandas as pd

csv_total = 'data_classifier_total.csv'
df = pd.read_csv(csv_total)
y = df['category']
y = pd.DataFrame(y.replace(to_replace={'2orSCSDM':0,'211CascadeSDM':1,'3orCascadeSDM':2,'2orGMSDM':3}))

x = df[['SNR','OSR','Power']]
df_cod = pd.concat([x,y], axis=1)

df_cod.to_csv('data_classifier_total_cod.csv', index=False)
# %%
