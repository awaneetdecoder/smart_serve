import 'package:flutter/material.dart';
import '../../models/token_model.dart';
import '../../services/queue_service.dart';


class QueueProvider with ChangeNotifier {
  final QueueService _queueService = QueueService();

  TokenModel?       _activeToken;   // The currently WAITING token
  List<TokenModel>  _userTokens  = []; // All user tokens
  bool              _isLoading   = false;
  String?           _errorMessage;

  // Public getters
  TokenModel?      get activeToken  => _activeToken;
  List<TokenModel> get userTokens   => _userTokens;
  bool             get isLoading    => _isLoading;
  String?          get errorMessage => _errorMessage;
  bool             get hasActiveToken => _activeToken != null;

 
  Future<bool> joinQueue({
    required int userId,
    required String tokenType,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final token = await _queueService.joinQueue(
        userId:    userId,
        tokenType: tokenType,
      );

      if (token == null) {
        _errorMessage = 'Could not join queue. You may already be in queue.';
        _setLoading(false);
        return false;
      }

      // Store as active token
      _activeToken = token;

      
      await _refreshWaitTime(userId);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to join queue. Check your connection.';
      _setLoading(false);
      return false;
    }
  }

 
  
  Future<void> loadUserTokens(int userId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final tokens = await _queueService.getUserTokens(userId);
      _userTokens = tokens;

      // Find the active (WAITING) token among all tokens
      
      final activeList = tokens
          .where((t) => t.isActive && !t.isDeleted)
          .toList();

      _activeToken = activeList.isNotEmpty ? activeList.first : null;

      // If there's an active token, refresh its wait time
      if (_activeToken != null) {
        await _refreshWaitTime(userId);
      }

      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Could not load queue data.';
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // cancelToken()
  // WHAT: User cancels their active token (soft delete on backend).
  //       After cancellation, _activeToken becomes null.
 
  Future<bool> cancelToken() async {
    if (_activeToken == null) return false;

    _setLoading(true);

    try {
      final success = await _queueService.cancelToken(_activeToken!.id);

      if (success) {
        _activeToken = null; // Remove from UI immediately
        // Also update it in the _userTokens list
        _userTokens = _userTokens
            .map((t) => t.id == _activeToken?.id
                ? t.copyWith(status: 'CANCELLED')
                : t)
            .toList();
      } else {
        _errorMessage = 'Could not cancel token. Please try again.';
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = 'Failed to cancel token.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> _refreshWaitTime(int userId) async {
    if (_activeToken == null) return;

    final waitMinutes = await _queueService.getWaitTime(userId);

    if (waitMinutes >= 0) {
      // Estimate people ahead: waitMinutes / 5 (backend uses 5 min per person)
      final peopleAhead = (waitMinutes / 5).round();

      _activeToken = _activeToken!.copyWith(
        estimatedWaitMinutes: waitMinutes,
        peopleAhead:          peopleAhead,
      );
      notifyListeners();
    }
  }

  void clearQueue() {
    _activeToken  = null;
    _userTokens   = [];
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _isLoading = value;
    notifyListeners();
  });
}
}