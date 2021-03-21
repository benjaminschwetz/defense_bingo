  FROM jcoenep/ambiorix
RUN echo "options(repos = c(CRAN = 'https://packagemanager.rstudio.com/all/latest'))" >> /usr/local/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN R -e "install.packages('ambiorix')"
RUN R -e "install.packages('htmltools')"
RUN R -e "install.packages('purrr')"
RUN R -e "install.packages('future')"
RUN R -e "install.packages('glue')"
RUN R -e "install.packages('rlist')"
RUN R -e "install.packages('knitr')"
COPY . .
CMD R -e "options(ambiorix.host='0.0.0.0', 'ambiorix.port'=8080);source('app.R')"
