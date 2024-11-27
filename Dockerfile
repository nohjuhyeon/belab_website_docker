# Python 3.10 이미지를 기반으로 생성
FROM python:3.10

# 최신 ChromeDriver 설치
RUN CHROMEDRIVER_VERSION=$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE) && \
    wget -q "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /usr/local/bin/ && \
    rm chromedriver_linux64.zip

# Google Chrome 설치
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# cron 및 tzdata 설치
RUN apt-get update && \
    apt-get install -y cron tzdata && \
    rm -rf /var/lib/apt/lists/*

# 시간대 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 작업 디렉토리 설정
WORKDIR /app

ARG BRANCH_NAME=belab_website
ARG DIR_NAME=belab_website # 변경대상

# Git repository clone
RUN git clone https://github.com/nohjuhyeon/news_website ${DIR_NAME} # 변경대상
WORKDIR /app/${DIR_NAME}

# Git 사용자 정보 설정
RUN git config --global user.email "njh2720@gmail.com"
RUN git config --global user.name "nohjuhyeon"

# Requirements 설치
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install -r requirements.txt

# 작업 디렉토리 이동
WORKDIR /app/${DIR_NAME}

# 컨테이너 시작 시 uvicorn 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
