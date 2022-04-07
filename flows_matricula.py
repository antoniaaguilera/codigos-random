import pandas as pd
import plotly.graph_objects as go
# --- SANKEY DIAGRAM --- #
df = pd.read_stata('/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/data/output/flows_mat.dta')
df
apply_sae = 6886+59368+214979
apply_sae
dont_apply = 77199+2385934
dont_apply
dropouts = 49762
dropouts
enrollment_2021 = 2997191
diff_school_2021 = 214979+77199
diff_school_2021
same_school_2021 = 59368+2385934
same_school_2021
new_students_2021=179620
new_students_2021

  plot = go.Figure(go.Sankey(
    node = {
        "label": ["Enrollment 2020 (2,794,128)", "New Student (179,620)", "Apply Through SAE (281,233)", "Don't Apply Through SAE (2,463,133)", "Dropouts (49,762)", "Not SAE (80,091)", "Diff School (292,178)", "Same School (2,445,302)","New Students (179,620)", "Enrollment 2021 (2,997,191)"],
        #"Enrollment Oct 2020","Don't Apply", "Applies through SAE", "Come from SAE", "Don't Enroll in Assignment", "Come from the same school", "","Changed Schools-not SAE", ""],
        "x": [0, 0,   0.3, 0.3,  0.7,   0.77,   0.77,     0.77,   0.77, 0.99999],
        "y": [0, 1, 0.91, 0.43, 0.000001, 1, 0.87, 0.42, 0.95, 0],
        'pad':5},
    link = {
        "source": [0, 0, 0, 1, 1, 3, 3, 2, 2, 2, 2, 5, 6, 7, 8],
        "target": [2, 3, 4, 2, 5, 6, 7, 6, 7, 8, 4, 9, 9, 9, 9 ],
        "value":  [apply_sae,dont_apply , dropouts, 179620, 80091, 77199, 2385934, 214979, 59368, 179620, 6886, 80091, diff_school_2021, same_school_2021, new_students_2021]}))

plot.show()

#plot.add_annotation(dict(font=dict(color="black",size=12), x=1.13, y=0.5, showarrow=False, text='Enrollment'))
#plot.add_annotation(dict(font=dict(color="black",size=12), x=1.1, y=0.42, showarrow=False, text='2021'))


plot.write_html("/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/output_random/flows_enrollment.html")

# If you need to save this file as a standalong html file:
#fig.write_html("/Volumes/GoogleDrive-106163685978679026504/.shortcut-targets-by-id/1flx2_T-4zb07TPZH6ge-VlnO1_2eiIeR/ConsiliumBots/1_Projects/4_DFM/DFM Chile/Entregables/rutas_educacion.html")
plot.write_image("/Users/antoniaaguilera/ConsiliumBots Dropbox/antoniaaguilera@consiliumbots.com/output_random/enrollment_flows.png")
