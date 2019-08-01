import 'dart:io';

import 'package:args/args.dart';
import 'package:bambam/argParser.dart';
import 'package:bambam/bamRequest.dart';

final CommandLineParser commandLineParser = new CommandLineParser();

main(List<String> arguments) async {
  ArgResults testParams = commandLineParser.parseArgs(arguments);
  
  print("DURATION FROM COMMAND LINE: ${testParams.arguments}");
  print("Amount of arguments passed: ${testParams.options.length}");
  
  final bamReportList = List<BamReport>();

  final bamRequestList = List.generate(int.parse(testParams['users']), (index) {
    return BamRequest(testParams['url']);
  });

  bamRequestList.map((request) => request.stream).forEach((stream) {
    stream.listen(
      (data){
      bamReportList.add(data);
    },
    onError: (err) {
      print('Error: $err');
    },
      cancelOnError: false
    );
  });


  Future.delayed(Duration(seconds: int.parse(testParams['duration'])), () {
    bamRequestList.map((request) => request.closeStream());
    generateReport(bamReportList);
    exit(0);
  });  
}

generateReport(List<BamReport> reportList) {
  var avgLatency = reportList.map((report) => report.latency.inMilliseconds).reduce((report1, report2) => report1 + report2) / reportList.length;
  print("""
  ----------------------------------------
  Performance Report
  Average Latency: ${avgLatency.toStringAsFixed(2)} ms
  # of request: ${reportList.length}
  """);
}
