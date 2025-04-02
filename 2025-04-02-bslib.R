library(tidyverse)

library(shiny)
library(bslib)

ui = bslib::page_sidebar(
  theme = bs_theme() |>
    bs_theme_update(preset = "cosmo"),
  
  title = "This is our Shiny app",
  sidebar = bslib::sidebar(
    h3("Likelihood"),
    sliderInput("x", "# of heads", min=0, max=100, value=7),
    sliderInput("n", "# of tosses", min=0, max=100, value=10),
    
    h3("Prior"),
    numericInput("a", "# of prior heads", value=5),
    numericInput("b", "# of prior tails", value=5),
  ),
  
  navset_card_tab(
    nav_panel(
      title = "Plot",
      card(
        card_header(
          #"Plot",
          popover(
            fontawesome::fa("gear", title = "Settings"),
            title = "Settings",
            checkboxInput("bw", "Use theme_bw", value=FALSE),
            checkboxInput("facet", "Use facets", value=FALSE)
          ),
          class = "bg-primary"
        ),
        
        card_body(
          plotOutput("plot")
        ),
        full_screen = TRUE
      )
    ),
    nav_panel(
      title = "Table",
      card(
        #card_header(
        #  "Table",
        #  class = "bg-secondary"
        #),
        card_body(
          tableOutput("table")
        )
      )
    )
  )
)

server = function(input, output, session) {
  bs_themer()
  
  
  # Responsible for keeping the n values < x
  observe({
    updateSliderInput(inputId = "n", min=input$x)  
  })
  
  # Render table of summary statistics
  output$table = renderTable({
    
    print("Calculating the table!")
    
    df() |> # Need to use () since df is a reactive
      group_by(distribution) |>
      summarize(
        mean = sum(p*density) / n(),
        median = p[(cumsum(density/n())) >= 0.5][1],
        q025 = p[(cumsum(density/n())) >= 0.025][1],
        q975 = p[(cumsum(density/n())) >= 0.975][1]
      )
  })
  
  # Render plot
  output$plot = renderPlot({
    
    print("Calculating the plot!")
    
    g = ggplot(df(), aes(x=p, y=density, color=distribution)) + 
      geom_line(linewidth=1.5)+
      geom_ribbon(aes(ymax=density, fill=distribution),ymin=0, alpha=0.5)
    
    if (input$bw) 
      g = g + theme_bw()
    
    if (input$facet)
      g = g +facet_wrap(~distribution)
    
    g
  })
  
  # Reactive that calculates distributions
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
          (\(x) {x / (sum(x) / n())})(), # Normalize likelihood for common scale
        posterior = dbeta(p, input$x + input$a, input$n - input$x + input$b)
      ) |>
      pivot_longer(
        cols = -p, names_to = "distribution", values_to = "density"
      ) |>
      mutate(
        # Factor to keep order: prior -> likelihood -> posterior
        distribution = as_factor(distribution)
      )
  })
}

thematic::thematic_shiny()

shinyApp(ui = ui, server = server)
