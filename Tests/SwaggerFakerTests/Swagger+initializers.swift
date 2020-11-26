@testable import Swagger

extension ArraySchema {
    init(items: ArraySchemaItems) {
        self.init(items: items,
                  minItems: nil,
                  maxItems: nil,
                  additionalItems: nil,
                  uniqueItems: false)
    }
}

extension IntegerSchema {
    init(format: IntegerFormat? = nil,
         minimum: Int? = nil,
         exclusiveMinimum: Int? = nil,
         maximum: Int? = nil,
         exclusiveMaximum: Int? = nil,
         multipleOf: Int? = nil) {
        self.init(format: format,
                  minimum: minimum,
                  maximum: maximum,
                  exclusiveMinimum: exclusiveMinimum,
                  exclusiveMaximum: exclusiveMaximum,
                  multipleOf: multipleOf)
    }
}

extension NumberSchema {
    init(format: NumberFormat? = nil,
         minimum: Double? = nil,
         exclusiveMinimum: Double? = nil,
         maximum: Double? = nil,
         exclusiveMaximum: Double? = nil,
         multipleOf: Double? = nil) {
        self.init(format: format,
                  maximum: maximum,
                  exclusiveMaximum: exclusiveMaximum,
                  minimum: minimum,
                  exclusiveMinimum: exclusiveMinimum,
                  multipleOf: multipleOf)
    }
}

extension StringSchema {
    init(format: StringFormat? = nil, minLength: Int? = nil, maxLength: Int? = nil) {
        self.init(format: format, maxLength: maxLength, minLength: minLength)
    }
}
