FROM swift:5.3.1

WORKDIR /OpenApiStubGenerator
COPY . /OpenApiStubGenerator
RUN make install
