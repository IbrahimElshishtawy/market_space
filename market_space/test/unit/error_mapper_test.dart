import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/core/errors/app_exception.dart';
import 'package:market_space/core/errors/app_failure.dart';
import 'package:market_space/core/errors/error_mapper.dart';

void main() {
  group('ErrorMapper', () {
    test('maps NetworkException to NetworkFailure', () {
      const exception = NetworkException();
      final failure = ErrorMapper.map(exception);
      expect(failure, isA<NetworkFailure>());
    });

    test('maps TimeoutException to TimeoutFailure', () {
      const exception = TimeoutException();
      final failure = ErrorMapper.map(exception);
      expect(failure, isA<TimeoutFailure>());
    });

    test('maps UnauthorizedException to UnauthorizedFailure', () {
      const exception = UnauthorizedException();
      final failure = ErrorMapper.map(exception);
      expect(failure, isA<UnauthorizedFailure>());
    });

    test('maps ValidationException with details to ValidationFailure with fieldErrors', () {
      const exception = ValidationException(
        message: 'Validation failed',
        details: [
          {'field': 'phone', 'issue': 'Invalid phone number'},
          {'field': 'price', 'issue': 'Price must be positive'},
        ],
      );
      final failure = ErrorMapper.map(exception);
      expect(failure, isA<ValidationFailure>());
      final validationFailure = failure as ValidationFailure;
      expect(validationFailure.fieldErrors['phone'], 'Invalid phone number');
      expect(validationFailure.fieldErrors['price'], 'Price must be positive');
    });

    test('maps Dio connection error to NetworkFailure', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/listings'),
        type: DioExceptionType.connectionError,
      );
      final failure = ErrorMapper.map(dioException);
      expect(failure, isA<NetworkFailure>());
    });

    test('maps Dio badResponse 404 to NotFoundFailure', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/listings/123'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/listings/123'),
          statusCode: 404,
          data: {'error': {'message': 'Listing not found', 'code': 'NOT_FOUND'}},
        ),
      );
      final failure = ErrorMapper.map(dioException);
      expect(failure, isA<NotFoundFailure>());
      expect(failure.userFriendlyMessage, 'Listing not found');
    });
  });
}
