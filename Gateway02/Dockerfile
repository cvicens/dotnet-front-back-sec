ARG BUILD_IMAGE
ARG RUNTIME_IMAGE

FROM ${BUILD_IMAGE} AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Build runtime image

FROM ${RUNTIME_IMAGE}
ARG APP_NAME
ENV DLL_NAME=${APP_NAME}.dll

WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["sh", "-c", "dotnet ${DLL_NAME}"]