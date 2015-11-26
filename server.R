
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

#Built heavily upon https://github.com/rstudio/shiny-examples/tree/master/060-retirement-simulation
library(shiny)

paramNames <- c("n_pairs", "ave_wear_days", "wear_var",
                "death_chance", "n_sim")

# Define server logic required to generate and plot a random distribution
#
# Idea and original code by Pierre Chretien
# Small updates by Michael Kapler
#
shinyServer(function(input, output, session) {
  getParams <- function() {
    
    params <- lapply(paramNames, function(p) {
      input[[p]]
    })
    names(params) <- paramNames
    params
  }
  
  # Function that generates scenarios and computes NAV. The expression
  # is wrapped in a call to reactive to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically
  #     re-executed when inputs change
  #
  run_sock <- reactive(do.call(simulate_sock, getParams()))
  
  # Expression that plot NAV paths. The expression
  # is wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically
  #     re-executed when inputs change
  #  2) Its output type is a plot
  #
  output$distPlot <- renderPlot({
    plot_sock(run_sock())
  })

  
})
simulate_sock <- function(n_pairs = 10, ave_wear_days = 50,
                         wear_var = 1, death_chance = 1, n_sim = 200) {
  #-------------------------------------
  # Inputs
  #-------------------------------------
  
  # Number of pairs of socks in use
  n.pairs = n_pairs
  
  # Average number of days you can wear a sock before it breaks
  ave.wear.days = ave_wear_days
  
  # Variation in wear per day
  wear.var = wear_var / 10
  
  # Chance of dieing per day worn
  death.chance = death_chance / 100
  
  
  # Number of simulated pairs
  n.sim = n_sim
  
  
  #-------------------------------------
  # Simulation
  #-------------------------------------
  
  # number of days to simulate
  n.obs = 365
  
  # simulate Withdrawals
  sock = matrix(ave.wear.days, n.obs + 1, n.sim)
  for (n in 1:n.sim){
    for (j in 1:n.obs) {
      worn = NULL
      random.n <- sample(1:n.pairs, 1)
      if (random.n == 1){
        worn <- 1
      }else{
        worn <- 0
      }
      death = NULL
      random.n <- runif(1,0,1)
      if (random.n <= death.chance){
        death = 1
      }else{
        death = 0
      }
      wear = rnorm(1, 1, wear.var)
      if (wear < 0){
        wear = 0
      }  
      sock[j + 1, n] = sock[j, n] - (worn * wear) - (death * ave.wear.days)
    }
  }
  
  # once nav is below 0 => run out of money
  sock[ sock <= 0 ] = NA
  
  
  return(sock)
}

plot_sock <- function(sock) {
  
  layout(matrix(c(1,2,1,3),2,2))
  
  palette(c("black", "grey50", "grey30", "grey70", "#d9230f"))
  
  # plot all scenarios
  matplot(sock,
          type = 'l', lwd = 0.5, lty = 1, col = 1:5,
          xlab = 'Day', ylab = 'Days of wear left',
          main = 'Declining sock health over time')
  
  # plot % of socks still alive
  p.alive = 1 - rowSums(is.na(sock)) / ncol(sock)
  
  plot(100 * p.alive, las = 1, xlab = 'days', ylab = 'Percentage socks still running',
       main = 'Percentage of socks still in use', ylim=c(0,100))
  grid()
  
  # plot histogram of sock life
  ages <- apply(is.na(sock),2,which.max)
  ages[ ages == 1 ] = nrow(sock)
  
  
  hist(ages, xlim=c(0,nrow(sock)), breaks = 25, slab = "Age", main = "Age of death for socks")

}