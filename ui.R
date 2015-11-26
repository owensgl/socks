
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

#parameters for socks
#Number of pairs in use
#Average number of days wear per sock
#Variability in sock wear
#Chance of sock death per day use
#Number of sock pairs to simulate
library(shiny)



shinyUI(pageWithSidebar(
  headerPanel('Sock Simulator'),
  sidebarPanel(
    sliderInput("n_pairs", "Number of sock pairs in use:", min = 1, max = 20, value = 10),
    sliderInput("ave_wear_days", "Average number of days you get out of each sock:", min = 1, max = 100, value = 50, step = 1),
    sliderInput("wear_var", "Amount of variation in wear per day:", min = 0, max = 10, value = 5.0, step = 0.1),
    sliderInput("death_chance", "Chance of a sock being destroyed each day it is worn (in %):", min = 0.0, max = 10.0, value = 1.0, step = 0.1),
    sliderInput("n_sim", "Number of sock pairs simulated :", min = 10, max = 1000, value = 100, step = 10),
    p(actionButton("recalc",
                   "Re-run sock simulation", icon("random"))
    )
  ),
  mainPanel(
    plotOutput('distPlot',height="600px")
  )
)
)