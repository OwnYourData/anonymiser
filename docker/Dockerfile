FROM oydeu/dc-base
LABEL org.opencontainers.image.authors="Christoph Fabianek <christoph@ownyourdata.eu>"

COPY Gemfile.extend $RAILS_ROOT
RUN git config --global url."https://".insteadOf git:// && \
	bundle install && \
	bundle update

RUN mv public/index.html public/databud.html
COPY . .

CMD ["./script/init.sh"]

EXPOSE 3000
