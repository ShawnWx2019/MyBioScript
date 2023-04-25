######################################################################
#         Prj: Plot toolbox.
#         Assignment: v 0.0.1
#         Date: Aug 10, 2022
#         Author: Shawn Wang <shawnwang2016@126.com>
#         Location: HENU, Kaifeng, Henan, China
######################################################################

# check dependency --------------------------------------------------------


options("repos" = c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
if (!require('devtools')) install.packages('devtools');
if (!require('shiny')) install.packages('shiny');
if (!require('dashboardthemes')) install.packages('dashboardthemes');
if (!require('shinydashboard')) install.packages('shinydashboard');
if (!require("DT")) install.packages('DT');
if (!require('tidyverse')) install.packages('tidyverse');
if (!require('shinyjqui')) install.packages('shinyjqui');
if (!require('colourpicker')) install.packages('colourpicker');
if (!require('cowplot')) BiocManager::install("cowplot");
if (!require('readxl')) BiocManager::install("readxl");
if (!require('shinythemes')) BiocManager::install("shinythemes");
if (!require('shinyjs')) BiocManager::install("shinyjs");


# functions ---------------------------------------------------------------


pollen_dotplot <- function(
    left_tbl,right_tbl,left_label,right_label,left_color,right_color,dot_size,dot_alpha,
    xlim_min,xlim_max,ylim_min,ylim_max,vline_x,margin_l,margin_b
) {
  left_tbl <-
    left_tbl %>%
    mutate(sample = left_label)
  right_tbl <-
    right_tbl %>%
    mutate(sample = right_label)
  tbl = rbind(left_tbl,right_tbl)
  theme1 =   theme(
    axis.text = element_text(size = 12,color = "black"),
    axis.title = element_text(size = 14,color = "black"),
    axis.ticks = element_line(size = 1,color = "black"),
    panel.border = element_rect(size = 1.5),
    legend.position = "none"
  )
  theme2 =   theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.border = element_rect(size = 1.5),
    legend.position = "none"
  )
  point_plt =
    ggplot(
      tbl,aes(x = Phase,y = Amplitude,color = sample)
    )+
    geom_point(size = dot_size,alpha = dot_alpha)+
    scale_color_manual(
      values = c(left_color,right_color)
    )+
    xlim(c(xlim_min,xlim_max))+
    ylim(c(ylim_min,ylim_max))+
    geom_vline(xintercept = vline_x)+
    theme_bw()+
    theme1+
    theme(plot.margin = unit(c(0,0,0,0),"cm"))

  top_density <-
    ggplot(tbl,aes(x = Phase,color = sample))+
    geom_density()+
    scale_color_manual(
      values = c(left_color,right_color)
    )+
    theme_bw()+
    xlim(c(xlim_min,xlim_max))+
    theme2+
    theme(plot.margin = unit(c(1,0,0,margin_l),"cm"))

  right_density <-
    ggplot(tbl,aes(y = Amplitude,color = sample))+
    geom_density()+
    scale_color_manual(
      values = c(left_color,right_color)
    )+
    theme_bw()+
    ylim(c(ylim_min,ylim_max))+
    theme2+
    theme(plot.margin = unit(c(0,1,margin_b,0),"cm"))
  x.plt <-
    plot_grid(top_density,NULL,
              point_plt,right_density,
              axis = "l",
              nrow = 2,ncol = 2,
              #align = "hv",
              rel_widths = c(2,0.4),rel_heights = c(0.4,2)
    )
  return(x.plt)
}

# app ui ------------------------------------------------------------------


app_ui <- function(request) {
  navbarPage(
    theme = shinytheme("spacelab"),
    ## logo
    shinyDashboardLogoDIY(
      boldText = "Zhang Lab"
      ,mainText = "Easy plot toolbox"
      ,textSize = 14
      ,badgeText = "v 0.0.1"
      ,badgeTextColor = "white"
      ,badgeTextSize = 2
      ,badgeBackColor = "#40E0D0"
      ,badgeBorderRadius = 3
    ),
    tabPanel(
      useShinyjs(),
      title = "Pollen dotplot",
      icon = icon("braille"),
      sidebarLayout(
        div(id = "Sidebar1",
            sidebarPanel(
              width = 2,
              fileInput(
                inputId = "left_file",
                label ="Upload first table",
                accept = c(".txt",".csv",".xls",".xlsx",".tsv")
              ),
              fileInput(
                inputId = 'right_file',
                label = "Upload second table",
                accept = c(".txt",".csv",".xls",".xlsx",".tsv")
              ),
              actionButton("Check_input1","Check input data"),
              textInput(
                inputId = "left_id",
                label = "1st sample id",
                value = "left"
              ),
              textInput(
                inputId = "right_id",
                label = "2nd sample id",
                value = "right"
              ),
              colourpicker::colourInput(
                inputId = "left_color",
                label = "1st sample color",
                value = "gold"
              ),
              colourpicker::colourInput(
                inputId = "right_color",
                label = "2nd sample color",
                value = "purple"
              ),
              sliderInput(
                inputId = "point_size",
                label = "point size",
                min = 0,
                max = 0.3,
                step = 0.01,
                value = 0.1
              ),
              sliderInput(
                inputId = "point_alpha",
                label = "point transparency",
                min = 0,
                max = 1,
                step = 0.05,
                value = 0.4
              ),
              p("DO not contain special symbols such as ' ', '/'", style = "color: #7a8788;font-size: 12px; font-style:Italic"),
              textInput(
                inputId = "x_axis_min",
                label = "x axis limitation (min)",
                value = 150
              ),
              textInput(
                inputId = "x_axis_max",
                label = "x axis limitation (max)",
                value = 220
              ),
              textInput(
                inputId = "y_axis_min",
                label = "y axis limitation (min)",
                value = 0
              ),
              textInput(
                inputId = "y_axis_max",
                label = "y axis limitation (max)",
                value = 3
              ),
              textInput(
                inputId = "vline_x",
                label = "vertical line location",
                value = 183.559
              ),
              textInput(
                inputId = "margin_l",
                label = "adjust left space",
                value = 0.89
              ),
              textInput(
                inputId = "margin_b",
                label = "adjust bottom space",
                value = 1.03
              ),
              actionButton("Start1","Start")
            )),
        mainPanel (
          fluidPage(
            actionButton("toggleSidebar","Toggle sidebar"),
            tabsetPanel(
              tabPanel(
                title = "Check input data",height = "500px",width = "100%",collapsible = T,
                icon = icon("table"),
                collapsible = T,
                h3("Preview of 1st file"),
                DT::dataTableOutput(outputId = "left_file_out"),
                br(),
                h3("Preview of 2nd file"),
                DT::dataTableOutput(outputId = "right_file_out")
              ),
              tabPanel(
                title = "Plot",height = "500px",width = "100%",collapsible = T,
                icon = icon("braille"),
                jqui_resizable(
                  plotOutput("plot_out1")
                ),
                textInput(
                  inputId = "plt1_height",
                  label = "Plot height",
                  value = 12
                ),
                textInput(
                  inputId = "plt1_width",
                  label = "Plot width",
                  value = 12
                ),
                br(),
                h2("Download figure"),
                p("After filling in the width and height, click set figure size to confirm, and then click download", style = "color: green;font-size: 12px; font-style:Italic"),
                actionButton("plt1_set_size","Set figure size"),
                br(),
                downloadButton("plt1_down_png","Download png file"),
                downloadButton("plt1_down_pdf","Download pdf file")
              )
            )
          )
        )
      )
    )
  )
}


# server ui ---------------------------------------------------------------



app_server <- function(input, output, session) {
  observeEvent(
    input$toggleSidebar, {
      shinyjs::toggle(id = "Sidebar")
    }
  )

  left_tbl <- reactive({
    file1 <- input$left_file
    if(is.null(file1)) {return()}
    if(str_detect(file1$datapath,".csv")) {
      read.csv(file = file1$datapath)
    } else if (str_detect(file1$datapath,".xlsx")) {
      readxl::read_xlsx(
        path = file$datapath,sheet = 1
      )
    } else {
      read.table(file = file1$datapath,
                 sep="\t",
                 header = T,
                 stringsAsFactors = F)
    }
  })

  right_tbl <- reactive({
    file1 <- input$right_file
    if(is.null(file1)) {return()}
    if(str_detect(file1$datapath,".csv")) {
      read.csv(file = file1$datapath)
    } else if (str_detect(file1$datapath,".xlsx")) {
      readxl::read_xlsx(
        path = file$datapath,sheet = 1
      )
    } else {
      read.table(file = file1$datapath,
                 sep="\t",
                 header = T,
                 stringsAsFactors = F)
    }
  })
  var_list1 <- reactiveValues(data = NULL)
  observeEvent(
    input$Check_input1,
    {
      var_list1$left_d_out = as.data.frame(left_tbl())

      var_list1$right_d_out = as.data.frame(right_tbl())
    }
  )

  output$left_file_out = DT::renderDataTable({
    if(is.null(left_tbl())){return()}
    if(is.null(var_list1$left_d_out)){return()}
    var_list1$left_d_out
  })

  output$right_file_out = DT::renderDataTable({
    if(is.null(right_tbl())){return()}
    if(is.null(var_list1$right_d_out)){return()}
    var_list1$right_d_out
  })

  var_plot2_list<- reactiveValues(data = NULL)

  observeEvent(
    input$Start1,
    {
      var_plot2_list$left_id = as.character(input$left_id)
      var_plot2_list$right_id = as.character(input$right_id)
      var_plot2_list$left_color = as.character(input$left_color)
      var_plot2_list$right_color = as.character(input$right_color)
      var_plot2_list$point_size = as.numeric(input$point_size)
      var_plot2_list$point_alpha = as.numeric(input$point_alpha)
      var_plot2_list$x_axis_min = as.numeric(input$x_axis_min)
      var_plot2_list$x_axis_max = as.numeric(input$x_axis_max)
      var_plot2_list$y_axis_min = as.numeric(input$y_axis_min)
      var_plot2_list$y_axis_max = as.numeric(input$y_axis_max)
      var_plot2_list$vline_x = as.numeric(input$vline_x)
      var_plot2_list$margin_b = as.numeric(input$margin_b)
      var_plot2_list$margin_l = as.numeric(input$margin_l)

      var_plot2_list$plot_out <-
        pollen_dotplot(
          left_tbl = var_list1$left_d_out,right_tbl = var_list1$right_d_out,
          left_label = var_plot2_list$left_id,right_label = var_plot2_list$right_id,
          left_color = var_plot2_list$left_color,right_color = var_plot2_list$right_color,
          dot_size = var_plot2_list$point_size,dot_alpha = var_plot2_list$point_size,
          xlim_min =var_plot2_list$x_axis_min,xlim_max =  var_plot2_list$x_axis_max,
          ylim_min =var_plot2_list$y_axis_min,ylim_max =  var_plot2_list$y_axis_max,
          vline_x = var_plot2_list$vline_x,
          margin_l =  var_plot2_list$margin_l,margin_b =  var_plot2_list$margin_b
        )
    }
  )
  output$plot_out1 = renderPlot(
    {
      input$Start1
      if(is.null(var_list1$left_d_out)) {return()}
      if(is.null(var_list1$right_d_out)) {return()}
      if(is.null(var_plot2_list$vline_x)) {return()}
      var_plot2_list$plot_out
    }
  )

  figsize_plt1 <- reactiveValues(data = NULL)

  observeEvent(
    input$plt1_set_size,
    {
      figsize_plt1$width = as.numeric(input$plt1_width)
      figsize_plt1$height = as.numeric(input$plt1_height)
    }
  )

  output$plt1_down_png = downloadHandler(
    filename = function() {
      paste0(var_plot2_list$left_id,"_vs_",var_plot2_list$right_id,".png")
    },
    content = function(file) {
      ggsave(plot = var_plot2_list$plot_out,filename = file,
             width = figsize_plt1$width,
             height = figsize_plt1$height)
    }
  )

  output$plt1_down_pdf = downloadHandler(
    filename = function() {
      paste0(var_plot2_list$left_id,"_vs_",var_plot2_list$right_id,".pdf")
    },
    content = function(file) {
      ggsave(plot = var_plot2_list$plot_out,filename = file,
             width = figsize_plt1$width,
             height = figsize_plt1$height)
    }
  )


}


# run app -----------------------------------------------------------------


shinyApp(app_ui,app_server)
