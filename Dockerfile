FROM python:3.6

#create directories
RUN mkdir /prodigy
RUN mkdir /work
WORKDIR /prodigy
COPY ./prodigy*.whl /prodigy
COPY ./news_headlines.jsonl /prodigy
COPY ./prodigy.json /prodigy

# install Prodigy from wheel file
RUN pip install prodigy-1.10.4-cp36.cp37.cp38-cp36m.cp37m.cp38-linux_x86_64.whl
#install spacy module
RUN python -m spacy download en_core_web_sm
#set env variable for prodigy working environment
ENV prodigy_home /work

EXPOSE 80

ENTRYPOINT prodigy ner.manual ner_news blank:en ./news_headlines.jsonl --label PERSON,ORG,PRODUCT,LOCATION
