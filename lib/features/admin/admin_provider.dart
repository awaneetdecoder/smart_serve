import 'package:flutter/material.dart';
import '../../models/token_model.dart';
import '../../services/queue_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminProvider
// WHAT: Manages queue state for the ADMIN's perspective.
//       The admin sees ALL tokens, not just their own.
//
// Differences from QueueProvider:
//   QueueProvider → for regular users (their own tokens only)
//   AdminProvider → for admins (all tokens + ability to change statuses)
//
// WHY a separate provider instead of adding admin methods to QueueProvider?
//   Clean code: admin and user have completely different views of the queue.
//   Smaller files are easier to understand and debug.
// ─────────────────────────────────────────────────────────────────────────────
class AdminProvider with ChangeNotifier {
  final QueueService _queueService = QueueService();

  List<TokenModel> _allTokens   = []; // ALL tokens from the backend
  bool             _isLoading   = false;
  String?          _errorMessage;

  // Getters
  List<TokenModel> get allTokens    => _allTokens;
  bool             get isLoading    => _isLoading;
  String?          get errorMessage => _errorMessage;

  // ─────────────────────────────────────────────────────────────────────────
  // Derived / computed properties
  // WHY computed? These are calculated FROM _allTokens each time they're
  //     accessed. No need to store them separately — they stay in sync
  //     automatically whenever _allTokens changes.
  //
  // EXAMPLE: waitingTokens returns only entries where status == "waiting"
  //          If admin serves a customer and _allTokens updates, this
  //          automatically reflects the change.
  // ─────────────────────────────────────────────────────────────────────────

  // Tokens currently waiting (active in queue, not deleted)
  List<TokenModel> get waitingTokens =>
      _allTokens.where((t) => t.isActive && !t.isDeleted).toList();

  // Tokens currently being served
  List<TokenModel> get servingTokens =>
      _allTokens.where((t) => t.isServing).toList();

  // Total count of waiting customers (for the stat card)
  int get waitingCount => waitingTokens.length;

  // ─────────────────────────────────────────────────────────────────────────
  // loadAllTokens()
  // WHAT: Fetches all queue entries from /api/queue/all
  //       Called when admin opens the Admin Dashboard.
  //
  // WHY call this every time admin opens the screen?
  //   The queue changes constantly (new users joining, tokens being served).
  //   We need fresh data each time the admin looks at the dashboard.
  //   In a real app, you'd use WebSockets for real-time updates.
  //   For now, manual refresh is fine.
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> loadAllTokens() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final tokens = await _queueService.getAllTokens();
      // Sort by id (ascending) so oldest tokens appear first
      // WHY? First come, first served — token T-101 was before T-102
      tokens.sort((a, b) => a.id.compareTo(b.id));
      _allTokens = tokens;
      _setLoading(false);
    } catch (e) {
      _errorMessage = 'Could not load queue data.';
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // serveNextCustomer()
  // WHAT: Marks the first WAITING token as SERVING.
  //       This is what happens when admin clicks "Serve Next Customer".
  //
  // FLOW:
  //   1. Find the first waiting token (smallest ID = arrived first)
  //   2. Call PUT /api/queue/{id}/status?status=SERVING
  //   3. Backend updates DB and returns updated token
  //   4. Update our local list to reflect the change (immediate UI update)
  //
  // WHY update local list immediately?
  //   We could just reload all tokens after every action (loadAllTokens()).
  //   That works but makes an extra API call.
  //   Instead: update the local state immediately for instant UI feedback,
  //   then the data is already correct.
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> serveNextCustomer() async {
    // Find the first waiting token
    final nextToken = waitingTokens.isNotEmpty ? waitingTokens.first : null;

    if (nextToken == null) {
      _errorMessage = 'No customers waiting in queue.';
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      final updated = await _queueService.updateTokenStatus(nextToken.id, 'SERVING');

      if (updated != null) {
        // Update our local list: replace old token with updated one
        // WHY not reload everything? Faster UI update, fewer API calls.
        _allTokens = _allTokens.map((token) {
          return token.id == updated.id ? updated : token;
        }).toList();
      }

      _setLoading(false);
      return updated != null;
    } catch (e) {
      _errorMessage = 'Failed to update token status.';
      _setLoading(false);
      return false;
    }
  }

  
  Future<bool> skipToken(int tokenId) async {
    _setLoading(true);

    try {
      final updated = await _queueService.updateTokenStatus(tokenId, 'DONE');

      if (updated != null) {
        _allTokens = _allTokens.map((token) {
          return token.id == tokenId ? updated : token;
        }).toList();
      }

      _setLoading(false);
      return updated != null;
    } catch (e) {
      _errorMessage = 'Failed to skip token.';
      _setLoading(false);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // holdToken()
  // WHAT: Puts a specific token on hold (pauses their service).
  //       Status changes to ON_HOLD.
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> holdToken(int tokenId) async {
    _setLoading(true);

    try {
      final updated = await _queueService.updateTokenStatus(tokenId, 'ON_HOLD');

      if (updated != null) {
        _allTokens = _allTokens.map((token) {
          return token.id == tokenId ? updated : token;
        }).toList();
      }

      _setLoading(false);
      return updated != null;
    } catch (e) {
      _errorMessage = 'Failed to hold token.';
      _setLoading(false);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // markAsDone()
  // WHAT: Marks a currently SERVING token as DONE (service completed).
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> markAsDone(int tokenId) async {
    _setLoading(true);

    try {
      final updated = await _queueService.updateTokenStatus(tokenId, 'DONE');

      if (updated != null) {
        _allTokens = _allTokens.map((token) {
          return token.id == tokenId ? updated : token;
        }).toList();
      }

      _setLoading(false);
      return updated != null;
    } catch (e) {
      _errorMessage = 'Failed to complete token.';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}