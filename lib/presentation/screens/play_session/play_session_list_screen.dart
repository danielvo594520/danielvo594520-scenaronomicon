import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../domain/models/play_session_with_details.dart';
import '../../providers/play_session_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/play_session_card.dart';

/// 表示モード
enum ViewMode { list, calendar }

/// プレイ記録一覧画面
class PlaySessionListScreen extends ConsumerStatefulWidget {
  const PlaySessionListScreen({super.key});

  @override
  ConsumerState<PlaySessionListScreen> createState() =>
      _PlaySessionListScreenState();
}

class _PlaySessionListScreenState extends ConsumerState<PlaySessionListScreen> {
  ViewMode _viewMode = ViewMode.list;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(playSessionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プレイ記録'),
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == ViewMode.list
                  ? Icons.calendar_month
                  : Icons.list,
            ),
            tooltip: _viewMode == ViewMode.list ? 'カレンダー表示' : 'リスト表示',
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == ViewMode.list
                    ? ViewMode.calendar
                    : ViewMode.list;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'play_session_list_fab',
        onPressed: () => context.push('/sessions/new'),
        child: const Icon(Icons.add),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('エラー: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(playSessionListProvider),
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const EmptyStateWidget(
              message: 'プレイ記録がありません。\n＋ボタンから追加しましょう！',
              icon: Icons.event_note_outlined,
            );
          }

          if (_viewMode == ViewMode.list) {
            return _buildListView(sessions);
          } else {
            return _buildCalendarView(sessions);
          }
        },
      ),
    );
  }

  Widget _buildListView(List<PlaySessionWithDetails> sessions) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return PlaySessionCard(
          session: session,
          onTap: () => context.push('/sessions/${session.id}'),
        );
      },
    );
  }

  Widget _buildCalendarView(List<PlaySessionWithDetails> sessions) {
    // 日付ごとにセッションをグループ化
    final sessionsByDate = <DateTime, List<PlaySessionWithDetails>>{};
    for (final session in sessions) {
      final date = DateTime(
        session.playedAt.year,
        session.playedAt.month,
        session.playedAt.day,
      );
      sessionsByDate.putIfAbsent(date, () => []).add(session);
    }

    // 選択された日のセッション
    final selectedSessions = _selectedDay != null
        ? sessionsByDate[DateTime(
              _selectedDay!.year,
              _selectedDay!.month,
              _selectedDay!.day,
            )] ??
            []
        : <PlaySessionWithDetails>[];

    return Column(
      children: [
        TableCalendar<PlaySessionWithDetails>(
          locale: 'ja_JP',
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          eventLoader: (day) {
            final date = DateTime(day.year, day.month, day.day);
            return sessionsByDate[date] ?? [];
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            markersMaxCount: 3,
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonDecoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            formatButtonTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildSelectedDaySessions(selectedSessions),
        ),
      ],
    );
  }

  Widget _buildSelectedDaySessions(List<PlaySessionWithDetails> sessions) {
    if (_selectedDay == null) {
      return Center(
        child: Text(
          '日付をタップして\nプレイ記録を表示',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final dateFormatter = DateFormat('M月d日(E)', 'ja_JP');
    final dateText = dateFormatter.format(_selectedDay!);

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              '$dateTextのプレイ記録はありません',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '$dateText（${sessions.length}件）',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return PlaySessionCard(
                session: session,
                onTap: () => context.push('/sessions/${session.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
