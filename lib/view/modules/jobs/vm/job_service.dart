import 'package:creatify_mobile/core/http/http_service.dart';
import 'package:creatify_mobile/core/utils/app_url.dart';
import 'package:dio/dio.dart';

class JobApiService {
  final HttpService _networkService;

  JobApiService({required HttpService networkService}) : _networkService = networkService;

  Future<Response> getJobs(Map<String, dynamic> filters) async {
    return await _networkService.request(
      endpoints.getJobs,
      RequestMethod.get,
      queryParams: filters,
    );
  }

  Future<Response> createJob(Map<String, dynamic> data) async {
    return await _networkService.request(
      endpoints.createJob,
      RequestMethod.post,
      data: data,
    );
  }

  Future<Response> getAppliedJobs() async {
    return await _networkService.request(
      endpoints.getAppliedJobs,
      RequestMethod.get,
    );
  }

  Future<Response> getMyListings() async {
    return await _networkService.request(
      endpoints.getMyListings,
      RequestMethod.get,
    );
  }

  Future<Response> getFavoriteJobs() async {
    return await _networkService.request(
      endpoints.getFavoriteJobs,
      RequestMethod.get,
    );
  }

  Future<Response> applyToJob(String jobId, Map<String, dynamic> data) async {
    return await _networkService.request(
      endpoints.applyToJob(jobId),
      RequestMethod.post,
      data: data,
    );
  }

  Future<Response> toggleFavorite(String jobId) async {
    return await _networkService.request(
      endpoints.toggleJobFavorite(jobId),
      RequestMethod.post,
    );
  }

  Future<Response> closeJob(String jobId) async {
    return await _networkService.request(
      endpoints.closeJob(jobId),
      RequestMethod.post,
    );
  }

  Future<Response> deleteJob(String jobId) async {
    return await _networkService.request(
      endpoints.deleteJob(jobId),
      RequestMethod.delete,
    );
  }

  Future<Response> getJobApplications(String jobId) async {
    return await _networkService.request(
      endpoints.getJobApplications(jobId),
      RequestMethod.get,
    );
  }

  Future<Response> respondToApplication(String applicationId, Map<String, dynamic> data) async {
    return await _networkService.request(
      endpoints.respondToJobApplication(applicationId),
      RequestMethod.post,
      data: data,
    );
  }

  Future<Response> initializeJobApplicationPayment(String applicationId) async {
    return await _networkService.request(
      endpoints.initializeJobApplicationPayment(applicationId),
      RequestMethod.post,
    );
  }

  Future<Response> getRecentSearches() async {
    return await _networkService.request(
      endpoints.getRecentSearches,
      RequestMethod.get,
    );
  }

  Future<Response> saveRecentSearch(String query) async {
    return await _networkService.request(
      endpoints.saveRecentSearch,
      RequestMethod.post,
      data: {'query': query},
    );
  }

  Future<Response> deleteRecentSearch(String id) async {
    return await _networkService.request(
      endpoints.deleteRecentSearch(id),
      RequestMethod.delete,
    );
  }

  Future<Response> clearRecentSearches() async {
    return await _networkService.request(
      endpoints.clearRecentSearches,
      RequestMethod.delete,
    );
  }
}
