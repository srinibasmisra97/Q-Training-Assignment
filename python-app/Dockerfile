FROM python

RUN mkdir /app

WORKDIR /app

COPY ./ /app

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "app.py"]