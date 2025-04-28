# DFValidator

A powerful, fluent validation library for Delphi applications that makes data validation clean and easy.

## Features

- Fluent API for building validation rules
- Built-in validators for common data types (strings, integers, dates, emails)
- Easy extensibility to create custom validators
- Detailed validation results with custom error messages
- Zero external dependencies

## Installation

1. Add `DFValidator.pas` to your project
2. Add `DFValidator` to your unit's uses clause
3. Start validating!

## Quick Example

```pascal
uses
  DFValidator;

// Example 1: Validate username
var
  Username: string;
  ValidationResult: TDFValidationResult;
begin
  Username := 'john123';
  ValidationResult := TDFValidate.String
    .Required
    .MinLength(5)
    .MaxLength(20)
    .Matches('^[a-zA-Z0-9_]+$')
    .Validate(Username);
    
  if not ValidationResult.IsValid then
    ShowMessage(ValidationResult.ErrorMessage);
end;

// Example 2: Validate age
var
  Age: Integer;
  ValidationResult: TDFValidationResult;
begin
  Age := 15;
  ValidationResult := TDFValidate.Integer
    .Min(18)
    .Max(120)
    .Validate(Age);
    
  if not ValidationResult.IsValid then
    ShowMessage(ValidationResult.ErrorMessage);  // Will show error since age is under 18
end;

// Example 3: Validate email
var
  Email: string;
  ValidationResult: TDFValidationResult;
begin
  Email := 'user@example.com';
  ValidationResult := TDFValidate.Email
    .Required
    .Validate(Email);
    
  if not ValidationResult.IsValid then
    ShowMessage(ValidationResult.ErrorMessage);
end;
```

## Available Validators

### String Validator
- `Required()` - Makes the string required (non-empty)
- `MinLength(n)` - Sets minimum string length
- `MaxLength(n)` - Sets maximum string length
- `Matches(pattern)` - Validates string against a regular expression pattern

### Integer Validator
- `Min(n)` - Sets minimum value
- `Max(n)` - Sets maximum value

### Date Validator
- `After(date)` - Date must be after specified date
- `Before(date)` - Date must be before specified date

### Email Validator
- Pre-configured string validator with email pattern

## Creating Custom Validators

You can easily extend the library with your own validators:

```pascal
type
  TPhoneValidator = class(TDFValidator<string>)
  private
    FCountryCode: string;
  public
    constructor Create;
    function Validate(const Value: string): TDFValidationResult; override;
    function ForCountry(const ACountryCode: string): TPhoneValidator;
  end;
```

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
