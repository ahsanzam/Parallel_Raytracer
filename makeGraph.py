import plotly.plotly as py
from plotly.graph_objs import *
import plotly.offline as offline
import math, sys

def make_graph(test):
    #parse file
    filename = f"Results/{test}.txt"
    f = open(filename, "r")
    x = []
    y = []
    len1 = ": "
    len2 = " seconds with "
    len3 = " processors."
    for i,line in enumerate(f):
        if i==0: continue
        index0 = line.find(len1)+2
        index1 = line.find(len2)
        index2 = line.find("with ")+5
        index3 = line.find(" processors")
        x.append(line[index2:index3])
        y.append(float(line[index0:index1]))
    f.close()

    #make graph
    offline.init_notebook_mode()
    fig = dict(data = [Bar(x=x, y=y)], 
                layout = Layout(title=test,
                                showlegend=False, 
                                height=500, 
                                width=1000,
                                xaxis=dict(title="Number of Processes"),
                                yaxis=dict(title="Runtime in seconds")
                               )           
               )
    offline.plot(fig, image='png', image_filename=test, auto_open=False)
    


make_graph('siggraph_MPI_Myrinet')
# make_graph('spheres_MPI_Myrinet')
# make_graph('table_MPI_Myrinet')

# make_graph('siggraph_MPI_Infiniband')
# make_graph('spheres_MPI_Infiniband')
# make_graph('table_MPI_Infiniband')
