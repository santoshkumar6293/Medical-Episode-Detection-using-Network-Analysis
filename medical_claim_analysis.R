#Install packages for plot
install.packages("ggplot2")
library("ggplot2")

install.packages("dplyr")
library("dplyr")

#Install required packages for DB connection
install.packages('odbc')
library('odbc')
install.packages("RODBC")
library("RODBC")

#Connect to DB 
dbhandle <- odbcDriverConnect('driver={SQL Server}; server=CC-SQL16-IDS506; database=4C; rows_at_time = 1; trusted_connection=true')

#Load table has only diagnosis 25000 with lab codes and office visit removed 
vSQL25<-paste(" SELECT * FROM VERTICES_25000",sep="") 
eSQL25<-paste("SELECT * FROM EDGES_25000",sep="") 
vDF25<-sqlQuery(dbhandle,vSQL25)
eDF25<-sqlQuery(dbhandle,eSQL25)

#table has 8 diagnosis code with office visits filtered and lab test filtered PRUNED
vSQLAll<-paste(" SELECT * FROM VERTICES_COMBINED_TOP8_PRUNE",sep="")
eSQLAll<-paste("SELECT * FROM EDGES_COMBINED_TOP8_PRUNE",sep="") 
vAll<-sqlQuery(dbhandle,vSQLAll) 
eAll<-sqlQuery(dbhandle,eSQLAll)

close(dbhandle)

#Package iGraph
install.packages("igraph")
library("igraph")

#Package Network Graph
install.packages("network")
library("network") 

# For diagnosis 25000
# Turning networks into igraph objects
g25 <- graph.data.frame(d=eDF25, 
                        directed = FALSE, 
                        vertices=vDF25) 

E(g25)       # The edges of the "g25" object
V(g25)       # The vertices of the "g25" object

# Degree Centrality For diagnosis 25000
deg25 <- degree(g25)
mean(deg25) #- 21.17557
max(deg25)  #- 524

# Plot with curved edges (edge.curved=.1) and reduce arrow size:
plot(g25, edge.arrow.size=.4, edge.curved=.1, vertex.size=2,vertex.label= NA)

#Walktrap
wc <- walktrap.community(g25,
                         weights=V(g25)$Weight,
                         membership = TRUE)

#plot and save
jpeg('walktrapPlot25k.jpg')
plot(wc,
     g25, 
     vertex.size=2, 
     vertex.label= NA, 
     vertex.color="orange", 
     edge.arrow.size=.2, 
     edge.curved=0)
dev.off()

# number of communities - 18
sizes(wc)

#Check Hierarchical
is_hierarchical(clp) # FALSE

# community membership for each node
membership(clp) 


# how modular the graph partitioning is
modularity(wc) 
#0.5435666

#label community
lc25 <- label.propagation.community(g25,weights=V(g25)$WEIGHTS)
jpeg('lcplot25k.jpg')
plot(lc25,
     g25, 
     vertex.size=2, 
     vertex.label= NA,
     vertex.color="orange", 
     edge.arrow.size=.2, 
     edge.curved=0)
dev.off()

# number of communities -11
sizes(lc25)

# how modular the graph partitioning is
modularity(lc25) 
#0.5396196

##########################################################################
##########################################################################

#For table with 8 diagnosis code with office visits filtered and lab test filtered PRUNED
#Turning networks into igraph objects
gAll <- graph.data.frame(d=eAll, 
                         directed = FALSE, 
                         vertices=vAll)
E(gAll)       # The edges of the "gAll" object
V(gAll)       # The vertices of the "gAll" object

# Degree Centrality For diagnosis 25000
degAll <- degree(gAll)
mean(degAll) #- 36.9625
max(degAll)  #- 523

# Plot with curved edges (edge.curved=.1) and reduce arrow size:
plot(gAll, edge.arrow.size=.4, edge.curved=.1, vertex.size=4,vertex.label= NA)

#Walktrap
wcALL <- walktrap.community(gAll,weights=V(gAll)$Weight,membership = TRUE)

#plot and save
jpeg('walktrapPlotAll.jpg')
plot(wcALL,
     gAll, 
     vertex.size=2, 
     vertex.label= NA, 
     vertex.color="orange", 
     edge.arrow.size=.2, 
     edge.curved=0)
dev.off()

# number of communities -18
sizes(wcALL)

# community membership for each node
membership(wcALL) 


# how modular the graph partitioning is
modularity(wcALL) 
#0.4639313

#label community
lcAll <- label.propagation.community(gAll,weights=V(gAll)$WEIGHTS)
jpeg('lcplotAll.jpg')
plot(lcAll,
     gAll, 
     vertex.size=2, 
     vertex.label= NA, 
     vertex.color="orange", 
     edge.arrow.size=.2, 
     edge.curved=0)
dev.off()

# number of communities - 10
sizes(lcAll) 

# community membership for each node
membership(lcAll) 

# how modular the graph partitioning is
modularity(lcAll) 
# 0.06167514

#Result Analysis : For both tables, walktrap algorithm gives the highest number of community and modularity score indicating the best community partitioning  


