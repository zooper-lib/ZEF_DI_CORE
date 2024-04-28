import 'package:zef_di_core/src/implementations/internal_service_locator_adapter.dart';
import 'package:zef_di_core/zef_di_core.dart';

void initializeServiceLocator() {
  ServiceLocatorBuilder().withAdapter(InternalServiceLocatorAdapter()).build();
}
