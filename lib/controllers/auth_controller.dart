import 'package:get/get.dart';

class StudentController extends GetxController {

  final RxBool isLoading =  false.obs;

  final RxString name = "".obs;

  changeData(){
    name.value = "santhosh";
    name.refresh();
  }

  clearData(){
    name.value = "";
  }

}