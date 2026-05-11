#!/usr/bin/env python3
import os
import re

PROJECT_ROOT = r"c:\Users\Vincent\Desktop\8vo\IA\App ReservationFlowS\lib"

FIXES = {
    "features/auth/presentation/screens/login_screen.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../core/"),
        (r"import '\.\.\/\.\.\/providers/", r"import '../../../../presentation/providers/"),
    ],
    "features/auth/presentation/screens/register_screen.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../core/"),
        (r"import '\.\.\/\.\.\/providers/", r"import '../../../../presentation/providers/"),
    ],
    "features/profile/presentation/screens/profile_screen.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../core/"),
        (r"import '\.\.\/\.\.\/providers/", r"import '../../../../presentation/providers/"),
    ],
    "features/dashboard/presentation/screens/dashboard_screen.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../core/"),
        (r"import '\.\.\/\.\.\/providers/", r"import '../../../../presentation/providers/"),
    ],
    "features/dashboard/presentation/screens/components/admin_action_buttons.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
        (r"import '\.\.\/\.\.\/\.\.\/providers/", r"import '../../../../../presentation/providers/"),
    ],
    "features/dashboard/presentation/screens/components/dashboard_header.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
    ],
    "features/dashboard/presentation/screens/components/metric_card.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
    ],
    "features/dashboard/presentation/screens/components/upcoming_reservation_tile.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
    ],
    "features/dashboard/presentation/screens/components/utilization_chart.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
        (r"import '\.\.\/\.\.\/\.\.\/providers/", r"import '../../../../../presentation/providers/"),
    ],
    "features/dashboard/presentation/screens/modals/products_management_modal.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
        (r"import '\.\.\/\.\.\/\.\.\/providers/", r"import '../../../../../presentation/providers/"),
    ],
    "features/reservations/presentation/screens/reservation_screen.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../core/"),
        (r"import '\.\.\/\.\.\/providers/", r"import '../../../../presentation/providers/"),
    ],
    "features/reservations/presentation/screens/reservation_calendar_view.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../core/"),
        (r"import '\.\.\/\.\.\/providers/", r"import '../../../../presentation/providers/"),
    ],
    "features/reservations/presentation/screens/components/calendar_section.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
    ],
    "features/reservations/presentation/screens/components/description_screen.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
    ],
    "features/reservations/presentation/screens/components/reservation_summary.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
        (r"import '\.\.\/\.\.\/\.\.\/providers/", r"import '../../../../../presentation/providers/"),
    ],
    "features/reservations/presentation/screens/components/summary_row.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
    ],
    "features/reservations/presentation/screens/components/time_slot_grid.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
    ],
    "features/reservations/presentation/screens/components/videobeam_selector.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
    ],
    "features/requests/presentation/screens/requests_screen.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../core/"),
        (r"import '\.\.\/\.\.\/providers/", r"import '../../../../presentation/providers/"),
    ],
    "features/requests/presentation/screens/components/filter_chip.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
    ],
    "features/requests/presentation/screens/components/request_card.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
    ],
    "features/requests/presentation/screens/components/swipe_background.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
    ],
    "features/requests/presentation/screens/components/tab_header.dart": [
        (r"import '\.\.\/\.\.\/\.\.\/\.\.\/core/", r"import '../../../../../../../core/"),
    ],
}

def main():
    modified = 0
    checked = 0
    
    for rel_path, rules in FIXES.items():
        full_path = os.path.join(PROJECT_ROOT, rel_path)
        checked += 1
        
        if not os.path.exists(full_path):
            print(f"❌ NOT FOUND: {rel_path}")
            continue
        
        with open(full_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        orig_content = content
        
        for pattern, replacement in rules:
            content = re.sub(pattern, replacement, content)
        
        if content != orig_content:
            with open(full_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ FIXED: {rel_path}")
            modified += 1
        else:
            print(f"⏭️  SKIP: {rel_path}")
    
    print(f"\n{'='*60}")
    print(f"✨ Summary: {modified}/{checked} files modified")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()
