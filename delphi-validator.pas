unit DFValidator;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.RegularExpressions;

type
  /// <summary>
  /// Exception raised when validation fails
  /// </summary>
  EDFValidationException = class(Exception);

  /// <summary>
  /// Result of a validation operation
  /// </summary>
  TDFValidationResult = record
    IsValid: Boolean;
    ErrorMessage: string;
    constructor Create(AIsValid: Boolean; const AErrorMessage: string = '');
  end;

  /// <summary>
  /// Abstract validator class that all validators must inherit from
  /// </summary>
  TDFValidator<T> = class abstract
  public
    function Validate(const Value: T): TDFValidationResult; virtual; abstract;
    function IsValid(const Value: T): Boolean;
  end;

  /// <summary>
  /// String validator with common validation rules
  /// </summary>
  TDFStringValidator = class(TDFValidator<string>)
  private
    FMinLength: Integer;
    FMaxLength: Integer;
    FPattern: string;
    FRequired: Boolean;
  public
    constructor Create;
    function Validate(const Value: string): TDFValidationResult; override;
    function MinLength(ALength: Integer): TDFStringValidator;
    function MaxLength(ALength: Integer): TDFStringValidator;
    function Matches(const APattern: string): TDFStringValidator;
    function Required(ARequired: Boolean = True): TDFStringValidator;
  end;

  /// <summary>
  /// Integer validator with common validation rules
  /// </summary>
  TDFIntegerValidator = class(TDFValidator<Integer>)
  private
    FMinValue: Integer;
    FMaxValue: Integer;
    FHasMinValue: Boolean;
    FHasMaxValue: Boolean;
  public
    constructor Create;
    function Validate(const Value: Integer): TDFValidationResult; override;
    function Min(AValue: Integer): TDFIntegerValidator;
    function Max(AValue: Integer): TDFIntegerValidator;
  end;

  /// <summary>
  /// Date validator with common validation rules
  /// </summary>
  TDFDateValidator = class(TDFValidator<TDateTime>)
  private
    FMinDate: TDateTime;
    FMaxDate: TDateTime;
    FHasMinDate: Boolean;
    FHasMaxDate: Boolean;
  public
    constructor Create;
    function Validate(const Value: TDateTime): TDFValidationResult; override;
    function After(ADate: TDateTime): TDFDateValidator;
    function Before(ADate: TDateTime): TDFDateValidator;
  end;

  /// <summary>
  /// Email validator
  /// </summary>
  TDFEmailValidator = class(TDFStringValidator)
  public
    constructor Create;
    function Validate(const Value: string): TDFValidationResult; override;
  end;

  /// <summary>
  /// Factory class to create validators
  /// </summary>
  TDFValidate = class
  public
    class function String: TDFStringValidator;
    class function Integer: TDFIntegerValidator;
    class function Date: TDFDateValidator;
    class function Email: TDFEmailValidator;
  end;

implementation

{ TDFValidationResult }

constructor TDFValidationResult.Create(AIsValid: Boolean; const AErrorMessage: string);
begin
  IsValid := AIsValid;
  ErrorMessage := AErrorMessage;
end;

{ TDFValidator<T> }

function TDFValidator<T>.IsValid(const Value: T): Boolean;
begin
  Result := Validate(Value).IsValid;
end;

{ TDFStringValidator }

constructor TDFStringValidator.Create;
begin
  inherited;
  FMinLength := 0;
  FMaxLength := MaxInt;
  FPattern := '';
  FRequired := False;
end;

function TDFStringValidator.Validate(const Value: string): TDFValidationResult;
begin
  // Required check
  if FRequired and (Value = '') then
    Exit(TDFValidationResult.Create(False, 'Value is required'));

  // Only perform other validations if we have a value
  if Value <> '' then
  begin
    // Min length check
    if (FMinLength > 0) and (Length(Value) < FMinLength) then
      Exit(TDFValidationResult.Create(False, Format('Minimum length is %d characters', [FMinLength])));

    // Max length check
    if (Length(Value) > FMaxLength) then
      Exit(TDFValidationResult.Create(False, Format('Maximum length is %d characters', [FMaxLength])));

    // Pattern check
    if (FPattern <> '') and not TRegEx.IsMatch(Value, FPattern) then
      Exit(TDFValidationResult.Create(False, 'Value does not match the required pattern'));
  end;

  Result := TDFValidationResult.Create(True);
end;

function TDFStringValidator.MinLength(ALength: Integer): TDFStringValidator;
begin
  FMinLength := ALength;
  Result := Self;
end;

function TDFStringValidator.MaxLength(ALength: Integer): TDFStringValidator;
begin
  FMaxLength := ALength;
  Result := Self;
end;

function TDFStringValidator.Matches(const APattern: string): TDFStringValidator;
begin
  FPattern := APattern;
  Result := Self;
end;

function TDFStringValidator.Required(ARequired: Boolean): TDFStringValidator;
begin
  FRequired := ARequired;
  Result := Self;
end;

{ TDFIntegerValidator }

constructor TDFIntegerValidator.Create;
begin
  inherited;
  FMinValue := 0;
  FMaxValue := 0;
  FHasMinValue := False;
  FHasMaxValue := False;
end;

function TDFIntegerValidator.Validate(const Value: Integer): TDFValidationResult;
begin
  if FHasMinValue and (Value < FMinValue) then
    Exit(TDFValidationResult.Create(False, Format('Value must be greater than or equal to %d', [FMinValue])));

  if FHasMaxValue and (Value > FMaxValue) then
    Exit(TDFValidationResult.Create(False, Format('Value must be less than or equal to %d', [FMaxValue])));

  Result := TDFValidationResult.Create(True);
end;

function TDFIntegerValidator.Min(AValue: Integer): TDFIntegerValidator;
begin
  FMinValue := AValue;
  FHasMinValue := True;
  Result := Self;
end;

function TDFIntegerValidator.Max(AValue: Integer): TDFIntegerValidator;
begin
  FMaxValue := AValue;
  FHasMaxValue := True;
  Result := Self;
end;

{ TDFDateValidator }

constructor TDFDateValidator.Create;
begin
  inherited;
  FHasMinDate := False;
  FHasMaxDate := False;
end;

function TDFDateValidator.Validate(const Value: TDateTime): TDFValidationResult;
begin
  if FHasMinDate and (Value < FMinDate) then
    Exit(TDFValidationResult.Create(False, 'Date must be after the minimum date'));

  if FHasMaxDate and (Value > FMaxDate) then
    Exit(TDFValidationResult.Create(False, 'Date must be before the maximum date'));

  Result := TDFValidationResult.Create(True);
end;

function TDFDateValidator.After(ADate: TDateTime): TDFDateValidator;
begin
  FMinDate := ADate;
  FHasMinDate := True;
  Result := Self;
end;

function TDFDateValidator.Before(ADate: TDateTime): TDFDateValidator;
begin
  FMaxDate := ADate;
  FHasMaxDate := True;
  Result := Self;
end;

{ TDFEmailValidator }

constructor TDFEmailValidator.Create;
begin
  inherited;
  // Set up standard email validation pattern
  Matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
end;

function TDFEmailValidator.Validate(const Value: string): TDFValidationResult;
begin
  Result := inherited;
  if not Result.IsValid then
    Exit;
    
  if (Value <> '') and not Result.IsValid then
    Result := TDFValidationResult.Create(False, 'Invalid email address format');
end;

{ TDFValidate }

class function TDFValidate.String: TDFStringValidator;
begin
  Result := TDFStringValidator.Create;
end;

class function TDFValidate.Integer: TDFIntegerValidator;
begin
  Result := TDFIntegerValidator.Create;
end;

class function TDFValidate.Date: TDFDateValidator;
begin
  Result := TDFDateValidator.Create;
end;

class function TDFValidate.Email: TDFEmailValidator;
begin
  Result := TDFEmailValidator.Create;
end;

end.
