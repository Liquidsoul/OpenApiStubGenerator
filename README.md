# openapi-stub-generator

A tool to generate stubs from a an OpenAPI specification.

Basic commands for the project are declared in the `Makefile`. You can list them using `make help` or just `make`.

## Example

You can find example files in the `Examples/` folder and you can run one using `make docker_run_example`.

Below shows the result output given some inputs to show an example of what can be done.

Configuration file `Examples/config.json`

```json
{
  "defaults": {
    "array": {
      "type": "randomLength",
      "minimum": 1,
      "maximum": 1
    },
    "string": {
      "type": "randomFromList",
      "list": ["RER", "BUS", "METRO"]
    }
  }
}
```

OpenAPI specification `Examples/spec.yml`

```
openapi: 3.0.1
info:
  title: API
  version: "1"
servers:
- url: http://localhost:3000/
security: []
tags: []

paths:
  /test:
    get:
      summary: Endpoint
      operationId: endpoint
      responses:
        200:
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Result'

components:
  schemas:
    Result:
      type: object
      required:
        - currentTime
        - identifier
        - theoreticalNextStops
      properties:
        currentTime:
          type: string
          format: date-time
        identifier:
          type: string
          format: uuid
        name:
          type: string
        nextStops:
          $ref: '#/components/schemas/RealTimeNextStops'
        theoreticalNextStops:
          $ref: '#/components/schemas/TheoreticalNextStops'

    RealTimeNextStop:
      type: object
      required:
        - directionName
        - destinationName
        - status
      properties:
        directionId:
          type: string
        directionName:
          type: string
        destinationName:
          type: string
        servicePatternName:
          type: string
        waitingTimeInMinutes:
          type: integer
        status:
          type: string
          enum:
          - AVAILABLE_WAITING_TIME
          - ATDOCK
          - APPROACHING
          - TRANSIT
          - UNAVAILABLE
          - LEAVING
          - UNKNOWN

    TheoreticalNextStop:
      type: object
      required:
        - directionName
        - destinationName
      properties:
        directionId:
          type: string
        directionName:
          type: string
        destinationName:
          type: string
        servicePatternName:
          type: string
        dateTime:
          description: Date and time of next stop.
          type: string
          format: date-time
        isLast:
          description: True if this stop is the last stop before end of service for this direction.
          type: boolean
        isFirst:
          description: True if this stop is the first stop before end of service for this direction.
          type: boolean
```

Call

    open-api-stub-generator --spec-file Examples/spec.yml --definition Result --config-file Examples/config.json

Result

```json
{
  "theoreticalNextStops" : [
    {
      "dateTime" : "METRO",
      "directionName" : "BUS",
      "isFirst" : true,
      "destinationName" : "RER",
      "isLast" : false,
      "directionId" : "BUS",
      "servicePatternName" : "METRO"
    }
  ],
  "currentTime" : "METRO",
  "nextStops" : [
    {
      "status" : "METRO",
      "destinationName" : "BUS",
      "waitingTimeInMinutes" : 12,
      "directionId" : "BUS",
      "servicePatternName" : "BUS",
      "directionName" : "BUS"
    }
  ],
  "identifier" : "METRO",
  "name" : "RER"
}
```
