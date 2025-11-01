// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2025 Uvarov Oleg <uv.ol.al@gmail.com>

final defaultFilters = [
  'Starting new instance',
  'Default STARTUP',
  'Ready condition',
  'audit_log'
];

bool shouldFilterPayload(String? payload, List<String> filters) {
  if (payload == null) return false;

  for (final filter in filters) {
    if (payload.startsWith(filter)) {
      return true;
    }
  }
  return false;
}
