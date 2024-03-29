rm(list=ls())
setwd('C:/Users/Alejandro/Desktop/MateDeLaCoz/Reporte Individual/Datos')


facps <- read.csv('FACTANAL_RECODED.csv')
# VERY IMPORTANT: All that follows assumes dataset is correctly RECODIFIED,
# so this won't work with new, "raw" datasets. (I'm guessing recodification
# info will be best placed somewhere the main_dict.) Sep 25, 2019.
INEE <- which(facps$FUENTE=='INEE')

items <- facps[INEE,# Working only with INEE for now
               c(1:72)]
names(items)[1] <- "ITEM1"
#               paste('ITEM',c(1:72),sep='')]

# Following 'dictionary' contains items and thresholds from all categories and domains
# (it'll be easier to extract stuff from here)
main_dict <- list('Ambiente de trabajo'=list('Condiciones en el ambiente de trabajo'=list(items=c(1,3,2,4,5),
                                                                                          thresholds_domain=c(5,9,11,14)),
                                             thresholds_category=c(5,9,11,14)),
                  'Factores propios de la actividad'=list('Carga de trabajo'=list(items=c(6,12,7,8,9,10,11,65,66,67,68,13,14,15,16),
                                                                                   thresholds_domain=c(15,21,27,37)),
                                                           'Falta de control sobre el trabajo'=list(items=c(25,26,27,28,23,24,29,30,35,36),
                                                                                                    thresholds_domain=c(11,16,21,25)),
                                                           thresholds_category=c(15,30,45,60)),
                  'Organizaci�n del tiempo de trabajo'=list('Jornada de trabajo'=list(items=c(17,18),
                                                                                       thresholds_domain=c(1,2,4,6)),
                                                             'Interferencia en la relaci�n trabajo-familia'=list(items=c(19,20,21,22),
                                                                                                                 thresholds_domain=c(4,6,8,10)),
                                                             thresholds_category=c(5,7,10,13)),
                  'Liderazgo y relaciones en el trabajo'=list('Liderazgo'=list(items=c(31,32,33,34,37,38,39,40,41),
                                                                                thresholds_domain=c(9,12,16,20)),
                                                               'Relaciones en el trabajo'=list(items=c(42,43,44,45,46,69,70,71,72),
                                                                                               thresholds_domain=c(10,13,17,21)),
                                                               'Violencia'=list(items=c(57,58,59,60,61,62,63,64),
                                                                                thresholds_domain=c(7,10,13,16)),
                                                               thresholds_category=c(14,29,42,58)),
                  'Entorno organizacional'=list('Reconocimiento del desempe�o'=list(items=c(47,48,49,50,51,52),
                                                                                    thresholds_domain=c(6,10,14,18)),
                                                'Insuficiente sentido de pertenencia e inestabilidad'=list(items=c(55,56,53,54),
                                                                                                           thresholds_domain=c(4,6,8,10)),
                                                thresholds_category=c(10,14,18,23)),
                  global_thresholds=c(50,75,99,140))
threshold_labels <- c('Nulo o despreciable','Bajo','Medio','Alto','Muy alto')
threshold_colors <- c("#a7e831", "#809b31", "#cadba5", "#683c00", "#ef972d")

# To retrieve category given a domain (I'm sure there's an easier way!):
inverse_dict <- list('Condiciones en el ambiente de trabajo'=names(main_dict)[1],
                     'Carga de trabajo'=names(main_dict)[2],
                     'Falta de control sobre el trabajo'=names(main_dict)[2],
                     'Jornada de trabajo'=names(main_dict)[3],
                     'Interferencia en la relaci�n trabajo-familia'=names(main_dict)[3],
                     'Liderazgo'=names(main_dict)[4],
                     'Relaciones en el trabajo'=names(main_dict)[4],
                     'Violencia'=names(main_dict)[4],
                     'Reconocimiento del desempe�o'=names(main_dict)[5],
                     'Insuficiente sentido de pertenencia e inestabilidad'=names(main_dict)[5])

# Examples of how to extract info from the dictionary
 categoria <- 'Entorno organizacional'
 dominio <- 'Reconocimiento del desempe�o'
 main_dict[categoria][[1]][dominio][[1]]['thresholds_domain'][[1]]
 main_dict[categoria][[1]][dominio][[1]]['items'][[1]]
 main_dict[categoria][[1]]['thresholds_category'][[1]]
 main_dict['global_thresholds'][[1]]

get_category_total <- function(categoria,person){
  # categoria <- 'Entorno organizacional'
  items_category <- NULL
  for(dom in 1:(length(main_dict[categoria][[1]])-1)){
    items_category <- append(items_category,
                             main_dict[categoria][[1]][[dom]]['items'][[1]])
  }
  total_category <- sum(items[person,
                              paste('ITEM',items_category,sep='')])
  thrsh <- main_dict[categoria][[1]]['thresholds_category'][[1]]
  
  # I'm sure the following decisions can be written in a single line but whatever...
  if(total_category<thrsh[1]){
    thrsh_lab <- threshold_labels[1]
    thrsh_col <- threshold_colors[1]
  }
  else if(total_category<thrsh[2]){
    thrsh_lab <- threshold_labels[2]
    thrsh_col <- threshold_colors[2]
  }
  else if(total_category<thrsh[3]){
    thrsh_lab <- threshold_labels[3]
    thrsh_col <- threshold_colors[3]
  }
  else if(total_category<thrsh[4]){
    thrsh_lab <- threshold_labels[4]
    thrsh_col <- threshold_colors[4]
  }
  else{
    thrsh_lab <- threshold_labels[5]
    thrsh_col <- threshold_colors[5]
  }
  results <- list(total_category=total_category,
                  evaluation=thrsh_lab)
  return(results)
}




get_domain_total <- function(dominio,person){
  # dominio <- 'Violencia'
  categoria <- inverse_dict[dominio][[1]]
  items_dominio <- main_dict[categoria][[1]][dominio][[1]]['items'][[1]]
  
  total_domain <- sum(items[person,
                            paste('ITEM',items_dominio,sep='')])
  
  thrsh <- main_dict[categoria][[1]][dominio][[1]]['thresholds_domain'][[1]]
  
  # I'm sure the following decisions can be written in a single line but whatever...
  if(total_domain<thrsh[1]){
    thrsh_lab <- threshold_labels[1]
    thrsh_col <- threshold_colors[1]
  }
  else if(total_domain<thrsh[2]){
    thrsh_lab <- threshold_labels[2]
    thrsh_col <- threshold_colors[2]
  }
  else if(total_domain<thrsh[3]){
    thrsh_lab <- threshold_labels[3]
    thrsh_col <- threshold_colors[3]
  }
  else if(total_domain<thrsh[4]){
    thrsh_lab <- threshold_labels[4]
    thrsh_col <- threshold_colors[4]
  }
  else{
    thrsh_lab <- threshold_labels[5]
    thrsh_col <- threshold_colors[5]
  }
  results <- list(total_domain=total_domain,
                  evaluation=thrsh_lab)
  return(results)
}



# get_domain_total('Carga de trabajo',88)
# get_category_total('Entorno organizacional',99)


person <- 55
      #try(dev.off())
      #x11(width=8,height=11)
#pdf('reporte_individual_factores_riesgo.pdf',width = 8,height = 11)
y_coords_category <- c(1,2.5,4.5,7,9.5)
y_coords_domain <- 1:10
x_coord_category <- -.5
x_coord_domain <- 2

plot(NULL,ylim=c(11,0),xlim=c(-2.5,2.5), axes=FALSE, ann=FALSE)
mtext(side=3, text = paste("Resultados Individuales (FOLIO:",person, ")"), line=1.5, cex=2, f=2)
POL_x <- c(-2.35,-2.35,2.35,2.35)
POL_y <- c(0.2,1.6,1.6,0.2,1.6,3.5,3.5,1.6,3.5,5.5,5.5,3.5,5.5,8.7,8.7,5.5, 8.7,10.5,10.5,8.7)
fondos <- c("white", "snow1", "snow2", "cornsilk2","bisque2")
for(cat in 1:5){
  y_inf <- 1 + ((cat-1) * 4)
  y_sup <- cat * 4
  categoria <- names(main_dict)[cat]
  cat_tot <- get_category_total(categoria,person)
  polygon(POL_x, POL_y[y_inf:y_sup],
          density = NA, col=fondos[which(threshold_labels==cat_tot$evaluation)])
  polygon(POL_x, POL_y[y_inf:y_sup],
          density = c(0), col="black", lwd=c(3), lty=c(1))
   text(-1.5,y_coords_category[cat],
       categoria)
  text(x_coord_category,y_coords_category[cat],
       cat_tot$total_category,cex=1.5, f=2)
 }
for(dom in 1:10){
  dominio <- names(inverse_dict)[dom]
  dom_tot <- get_domain_total(dominio,person)
  text(.85,y_coords_domain[dom],
       dominio)
  text(x_coord_domain,y_coords_domain[dom],
       dom_tot$total_domain,cex=1.5, f=2)
  #color <- threshold_colors[which(threshold_labels==dom_tot$evaluation)]
  #polygon(c(-.65,-.65,-.35,-.35,3,3,4,4), c(0.2,1.8,1.8,0.2,NA, 1,2,1),
  #        density = c(10, 35), angle = c(90, 45), col=color, lwd=c(2,3), lty=c(2,4))
}

#dev.off()




