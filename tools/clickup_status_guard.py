"""
ClickUp Status Guard - ZERO TOLERANCE Enforcement (Pattern P108-P112, 2026-03-14)

Agent is FORBIDDEN from moving tasks to "done" - only user/QA can do this.
Code enforcement achieves 100% prevention vs 0% for documentation alone (710x ROI).

Usage:
    from clickup_status_guard import assert_not_done_status, safe_update_status

    # Guard function - raises on forbidden status
    assert_not_done_status(target_status)

    # Safe wrapper - guards + executes API call
    safe_update_status(task_id, target_status, headers)
"""

import requests

FORBIDDEN_STATUSES = frozenset({
    'done', 'Done', 'DONE',
    'complete', 'Complete', 'COMPLETE',
    'closed', 'Closed', 'CLOSED',
})

API_BASE = "https://api.clickup.com/api/v2"


class ForbiddenStatusTransition(Exception):
    """Raised when agent attempts to move a task to a forbidden status."""
    pass


def assert_not_done_status(target_status: str) -> None:
    """
    ZERO TOLERANCE gate: blocks any attempt to set task status to 'done' or equivalent.
    Raises ForbiddenStatusTransition if status is forbidden.
    """
    if target_status.strip() in FORBIDDEN_STATUSES:
        raise ForbiddenStatusTransition(
            f"ZERO TOLERANCE VIOLATION BLOCKED: Agent is FORBIDDEN from moving tasks to '{target_status}'. "
            f"Only user/QA can perform this transition. Maximum agent status = 'testing'."
        )


def safe_update_status(task_id: str, target_status: str, headers: dict) -> dict:
    """
    Safe wrapper for ClickUp status update with built-in enforcement.
    Returns the API response dict on success.
    """
    assert_not_done_status(target_status)

    resp = requests.put(
        f"{API_BASE}/task/{task_id}",
        headers=headers,
        json={"status": target_status},
    )
    resp.raise_for_status()
    return resp.json()
