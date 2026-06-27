import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../theme/colors.dart';
import '../theme/parchment_widgets.dart';
import '../models/property.dart';
import '../models/property_event.dart';
import '../data/property_addons_data.dart';
import '../data/property_events_data.dart';
import 'shop_screen.dart';

class HoldingsScreen extends ConsumerWidget {
  const HoldingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gold          = ref.watch(goldProvider);
    final properties    = ref.watch(propertiesProvider);
    final pendingEvents = ref.watch(pendingPropertyEventsProvider);
    final inGameDay     = ref.watch(inGameDayProvider);
    final owned         = {for (final p in properties) p.type: p};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Blacksmith shop shortcut ─────────────────────────
          if (owned.containsKey(PropertyType.blacksmith)) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AshenColors.surfaceAlt,
                  foregroundColor: AshenColors.copper,
                  side: const BorderSide(color: AshenColors.copper),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: const RoundedRectangleBorder(),
                ),
                icon: const Text('⚒', style: TextStyle(fontSize: 16)),
                label: const Text('VISIT THE IRON HEARTH',
                    style: TextStyle(letterSpacing: 2, fontSize: 13)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShopScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Owned properties ─────────────────────────────────
          if (properties.isNotEmpty) ...[
            const SectionHeading('YOUR HOLDINGS'),
            const SizedBox(height: 8),
            ...properties.map((p) {
              final event = pendingEvents
                  .where((e) => e.propertyId == p.id)
                  .firstOrNull;
              return _OwnedPropertyCard(
                property: p,
                gold: gold,
                inGameDay: inGameDay,
                pendingEvent: event,
                ref: ref,
              );
            }),
            const SizedBox(height: 20),
          ],

          // ── Available to purchase ────────────────────────────
          const SectionHeading('AVAILABLE TO PURCHASE'),
          const SizedBox(height: 12),
          ...PropertyType.values
              .where((type) => !owned.containsKey(type))
              .map((type) => _PurchaseCard(
                    type: type,
                    gold: gold,
                    onBuy: () => ref
                        .read(gameProvider.notifier)
                        .purchaseProperty(type),
                  )),
        ],
      ),
    );
  }
}

// ─── OWNED PROPERTY CARD ──────────────────────────────────────────────────────

class _OwnedPropertyCard extends StatelessWidget {
  final OwnedProperty property;
  final int gold;
  final int inGameDay;
  final PendingPropertyEvent? pendingEvent;
  final WidgetRef ref;

  const _OwnedPropertyCard({
    required this.property,
    required this.gold,
    required this.inGameDay,
    required this.pendingEvent,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final addons      = allAddons[property.type] ?? [];
    final unlockedIds = property.unlockedAddonIds.toSet();
    final allUnlocked = unlockedIds.length >= addons.length;

    AddonDef? nextAddon;
    for (final a in addons) {
      if (!unlockedIds.contains(a.id)) {
        nextAddon = a;
        break;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AshenColors.parchmentWarm, AshenColors.surface],
          stops: [0.0, 0.3],
        ),
        border: Border(
          left:   const BorderSide(color: AshenColors.gold, width: 3),
          top:    BorderSide(color: AshenColors.border, width: 0.5),
          right:  BorderSide(color: AshenColors.border, width: 0.5),
          bottom: BorderSide(color: AshenColors.border, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_propertyIcon(property.type),
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(property.name,
                          style: AshenText.body.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(_typeName(property.type),
                          style: AshenText.dim),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('+${property.goldPerMinute}g/min',
                        style: AshenText.gold.copyWith(fontSize: 12)),
                    if (allUnlocked)
                      const Text('FULLY UPGRADED',
                          style: TextStyle(
                              color: AshenColors.gold,
                              fontSize: 9,
                              letterSpacing: 1.5))
                    else
                      Text('${unlockedIds.length}/${addons.length} improvements',
                          style: AshenText.dim.copyWith(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),

          // ── Functional perk banner ───────────────────────────
          _PerkBanner(type: property.type),

          // ── Blacksmith shop action ───────────────────────────
          if (property.type == PropertyType.blacksmith)
            _ShopButton(context: context),

          // ── Tavern rest action ───────────────────────────────
          if (property.type == PropertyType.tavern)
            _TavernRestButton(inGameDay: inGameDay, ref: ref),

          // ── Pending event ────────────────────────────────────
          if (pendingEvent != null)
            _PropertyEventCard(event: pendingEvent!, ref: ref),

          // ── Improvements ────────────────────────────────────
          if (addons.isNotEmpty) ...[
            const Divider(color: AshenColors.border, thickness: 0.5, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
              child: Text('IMPROVEMENTS',
                  style: AshenText.dim.copyWith(fontSize: 10, letterSpacing: 1.5)),
            ),
            ...addons.map((addon) => _AddonRow(
                  addon: addon,
                  isUnlocked: unlockedIds.contains(addon.id),
                  isAvailable: addon == nextAddon,
                  canAfford: gold >= addon.cost,
                  onBuy: () => ref
                      .read(gameProvider.notifier)
                      .purchaseAddon(property.id, addon.id),
                )),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ─── PERK BANNER ─────────────────────────────────────────────────────────────

class _PerkBanner extends StatelessWidget {
  final PropertyType type;
  const _PerkBanner({required this.type});

  @override
  Widget build(BuildContext context) {
    final text = propertyPerk[type] ?? '';
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AshenColors.parchmentWarm,
        border: const Border(
          left: BorderSide(color: AshenColors.copper, width: 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✦ ',
              style: TextStyle(
                  color: AshenColors.copper, fontSize: 11)),
          Expanded(
            child: Text(text,
                style: AshenText.dim.copyWith(
                    fontSize: 11, color: AshenColors.parchment)),
          ),
        ],
      ),
    );
  }
}

// ─── TAVERN REST BUTTON ───────────────────────────────────────────────────────

class _TavernRestButton extends ConsumerWidget {
  final int inGameDay;
  final WidgetRef ref;
  const _TavernRestButton({required this.inGameDay, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final storedDay   = state.tavernRestDay ~/ 10;
    final restsToday  = state.tavernRestDay % 10;
    final restCount   = storedDay == inGameDay ? restsToday : 0;

    // Private Rooms addon allows 2 rests per day
    final tavern = state.properties
        .where((p) => p.type == PropertyType.tavern)
        .firstOrNull;
    final hasPrivateRooms =
        tavern?.unlockedAddonIds.contains('tavern_rooms') ?? false;
    final maxRests = hasPrivateRooms ? 2 : 1;

    final canRest = restCount < maxRests;
    final label = canRest
        ? 'REST PARTY  (free)'
        : 'RESTED TODAY  (${hasPrivateRooms ? "$restCount/$maxRests" : "once"})';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor:
                canRest ? AshenColors.copper : AshenColors.parchmentDim,
            side: BorderSide(
                color: canRest ? AshenColors.copper : AshenColors.border),
            shape: const RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            textStyle: const TextStyle(fontSize: 11, letterSpacing: 2),
          ),
          icon: Icon(Icons.hotel,
              size: 14,
              color: canRest ? AshenColors.copper : AshenColors.parchmentDim),
          label: Text(label),
          onPressed: canRest
              ? () => ref.read(gameProvider.notifier).restAtTavern()
              : null,
        ),
      ),
    );
  }
}

// ─── BLACKSMITH SHOP BUTTON ──────────────────────────────────────────────────

class _ShopButton extends StatelessWidget {
  final BuildContext context;
  const _ShopButton({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AshenColors.copper,
            side: const BorderSide(color: AshenColors.copper),
            shape: const RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            textStyle: const TextStyle(fontSize: 11, letterSpacing: 2),
          ),
          icon: const Text('⚒', style: TextStyle(fontSize: 13)),
          label: const Text('OPEN THE IRON HEARTH'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShopScreen()),
          ),
        ),
      ),
    );
  }
}

// ─── ADDON ROW ────────────────────────────────────────────────────────────────

class _AddonRow extends StatelessWidget {
  final AddonDef addon;
  final bool isUnlocked;
  final bool isAvailable;
  final bool canAfford;
  final VoidCallback onBuy;

  const _AddonRow({
    required this.addon,
    required this.isUnlocked,
    required this.isAvailable,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final nameColor = isUnlocked
        ? AshenColors.gold
        : isAvailable
            ? AshenColors.parchment
            : AshenColors.parchmentDim;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 8),
            child: Text(
              isUnlocked ? '✓' : isAvailable ? '›' : '·',
              style: TextStyle(
                fontSize: 14,
                color: isUnlocked
                    ? AshenColors.gold
                    : isAvailable
                        ? AshenColors.copper
                        : AshenColors.parchmentDim,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(addon.name,
                    style: AshenText.body.copyWith(
                        fontSize: 13,
                        color: nameColor,
                        fontWeight: isUnlocked
                            ? FontWeight.bold
                            : FontWeight.normal)),
                Text(addon.description,
                    style: AshenText.dim.copyWith(fontSize: 11)),
                if (isUnlocked && addon.incomeBonus > 0)
                  Text('+${addon.incomeBonus}g/min',
                      style: const TextStyle(
                          color: AshenColors.gold, fontSize: 11)),
              ],
            ),
          ),
          if (isAvailable && !isUnlocked) ...[
            const SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    canAfford ? AshenColors.copper : AshenColors.parchmentDim,
                side: BorderSide(
                    color: canAfford ? AshenColors.copper : AshenColors.border),
                shape: const RoundedRectangleBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: canAfford ? onBuy : null,
              child: Text('${addon.cost}g',
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
          if (isUnlocked)
            const Padding(
              padding: EdgeInsets.only(left: 8, top: 2),
              child: Text('BUILT',
                  style: TextStyle(
                      color: AshenColors.gold,
                      fontSize: 10,
                      letterSpacing: 1.5)),
            ),
        ],
      ),
    );
  }
}

// ─── PROPERTY EVENT CARD ──────────────────────────────────────────────────────

class _PropertyEventCard extends StatelessWidget {
  final PendingPropertyEvent event;
  final WidgetRef ref;
  const _PropertyEventCard({required this.event, required this.ref});

  @override
  Widget build(BuildContext context) {
    final def = propertyEventById(event.defId);
    if (def == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: AshenColors.surfaceAlt,
        border: const Border(
          top: BorderSide(color: AshenColors.copper, width: 1),
          bottom: BorderSide(color: AshenColors.border, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚡',
                  style: TextStyle(fontSize: 12, color: AshenColors.copper)),
              const SizedBox(width: 6),
              Text(def.title,
                  style: AshenText.body.copyWith(
                      fontSize: 13,
                      color: AshenColors.copper,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(def.description, style: AshenText.dim.copyWith(fontSize: 12)),
          const SizedBox(height: 10),
          ...def.choices.asMap().entries.map((entry) {
            final i      = entry.key;
            final choice = entry.value;
            final gold   = ref.read(goldProvider);
            final canAfford =
                choice.goldDelta >= 0 || gold >= -choice.goldDelta;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: canAfford
                        ? AshenColors.parchment
                        : AshenColors.parchmentDim,
                    side: BorderSide(
                        color: canAfford
                            ? AshenColors.copper
                            : AshenColors.border,
                        width: 0.5),
                    shape: const RoundedRectangleBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: canAfford
                      ? () => ref
                          .read(gameProvider.notifier)
                          .resolvePropertyEvent(event.propertyId, i)
                      : null,
                  child: Text(choice.label,
                      style: const TextStyle(fontSize: 12)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── PURCHASE CARD ────────────────────────────────────────────────────────────

class _PurchaseCard extends StatelessWidget {
  final PropertyType type;
  final int gold;
  final VoidCallback onBuy;

  const _PurchaseCard({
    required this.type,
    required this.gold,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final cost    = propertyCosts[type]!;
    final income  = baseIncomePerMinute[type]!;
    final addons  = allAddons[type] ?? [];
    final maxIncome = income + addons.fold(0, (s, a) => s + a.incomeBonus);
    final canBuy  = gold >= cost;
    final perk    = propertyPerk[type] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AshenColors.parchmentWarm, AshenColors.surface],
          stops: [0.0, 0.3],
        ),
        border: Border(
          left:   const BorderSide(color: AshenColors.inkRed, width: 3),
          top:    BorderSide(color: AshenColors.border, width: 0.5),
          right:  BorderSide(color: AshenColors.border, width: 0.5),
          bottom: BorderSide(color: AshenColors.border, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_propertyIcon(type), style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_displayName(type),
                    style: AshenText.body.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(perk,
                    style: AshenText.dim.copyWith(
                        fontSize: 12, color: AshenColors.parchment)),
                const SizedBox(height: 4),
                Text(
                  '+$income–${maxIncome}g/min  ·  ${cost}g to purchase',
                  style: AshenText.dim.copyWith(
                      fontSize: 11, color: AshenColors.parchmentDim),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  canBuy ? AshenColors.darkRed : AshenColors.border,
              foregroundColor: AshenColors.parchment,
              shape: const RoundedRectangleBorder(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: canBuy ? onBuy : null,
            child: Column(
              children: [
                const Text('BUY',
                    style: TextStyle(fontSize: 11, letterSpacing: 1)),
                Text('${cost}g',
                    style: TextStyle(
                        fontSize: 13,
                        color: canBuy
                            ? AshenColors.gold
                            : AshenColors.parchmentDim)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────

String _typeName(PropertyType type) => switch (type) {
      PropertyType.tavern       => 'Tavern',
      PropertyType.blacksmith   => 'Blacksmith',
      PropertyType.apothecary   => 'Apothecary',
      PropertyType.generalStore => 'General Store',
      PropertyType.stables      => 'Stables',
      PropertyType.castle       => 'Castle',
    };

String _displayName(PropertyType type) => switch (type) {
      PropertyType.tavern       => 'Tavern',
      PropertyType.blacksmith   => 'Blacksmith',
      PropertyType.apothecary   => 'Apothecary',
      PropertyType.generalStore => 'General Store',
      PropertyType.stables      => 'Stables',
      PropertyType.castle       => 'Castle',
    };

String _propertyIcon(PropertyType type) => switch (type) {
      PropertyType.tavern       => '🍺',
      PropertyType.blacksmith   => '⚒',
      PropertyType.apothecary   => '⚗',
      PropertyType.generalStore => '🛒',
      PropertyType.stables      => '🐴',
      PropertyType.castle       => '🏰',
    };
