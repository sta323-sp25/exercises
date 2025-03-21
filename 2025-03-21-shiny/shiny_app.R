library(tidyverse)

library(shiny)
library(bslib)

ui = bslib::page_sidebar(
  title = "This is our Shiny app",
  sidebar = bslib::sidebar(
    h3("Likelihood"),
    sliderInput("x", "# of heads", min=0, max=100, value=7),
    sliderInput("n", "# of tosses", min=0, max=100, value=10),
    
    h3("Prior"),
    numericInput("a", "# of prior heads", value=5),
    numericInput("b", "# of prior tails", value=5),
    
    checkboxInput("show_opt", "Show options", value=FALSE),
    conditionalPanel(
      "input.show_opt == true",
      h3("Options"),
      checkboxInput("bw", "Use theme_bw", value=FALSE),
      checkboxInput("facet", "Use facets", value=FALSE)
    )
    
  ),
  plotOutput("plot"),
  tableOutput("table")
)

server = function(input, output, session) {
  
  observe({
    updateSliderInput(inputId = "n", min=input$x)  
  })
  
  output$table = renderTable({
    df() |>
      group_by(distribution) |>
      summarize(
        mean = sum(p*density) / n(),
        median = p[(cumsum(density/n())) >= 0.5][1],
        q025 = p[(cumsum(density/n())) >= 0.025][1],
        q975 = p[(cumsum(density/n())) >= 0.975][1]
      )
  })
  
  output$plot = renderPlot({
    g = ggplot(df(), aes(x=p, y=density, color=distribution)) + 
      geom_line(linewidth=1.5)+
      geom_ribbon(aes(ymax=density, fill=distribution),ymin=0, alpha=0.5)
    
    if (input$bw) 
      g = g + theme_bw()
    
    if (input$facet)
      g = g +facet_wrap(~distribution)
    
    g
  })
  
  df = reactive({
    req(input$a)
    req(input$b)
    
    validate(
      need(input$a > 0, "# of prior heads needs to be >0"),
      need(input$b > 0, "# of prior tails needs to be >0")
    )
    
    tibble(
      p = seq(0, 1, length.out=1001)
    ) |>
      mutate(
        prior = dbeta(p, input$a, input$b),
        likelihood = dbinom(input$x, input$n, p) |>
          (\(x) {x / (sum(x) / n())})(),
        posterior = dbeta(p, input$x + input$a, input$n - input$x + input$b)
      ) |>
      pivot_longer(
        cols = -p, names_to = "distribution", values_to = "density"
      ) |>
      mutate(
        distribution = as_factor(distribution)
      )
  })
}

shinyApp(ui = ui, server = server)
