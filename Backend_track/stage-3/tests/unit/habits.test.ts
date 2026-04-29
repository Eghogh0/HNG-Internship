import { describe, it, expect } from 'vitest';
import { toggleHabitCompletion } from '@/lib/habits';
import type { Habit } from '@/types/habit';

const baseHabit: Habit = {
  id: '1',
  userId: 'user1',
  name: 'Test',
  description: '',
  frequency: 'daily',
  createdAt: '2024-01-01',
  completions: [],
};

describe('toggleHabitCompletion', () => {
  it('adds a completion date when the date is not present', () => {
    const date = '2024-01-10';
    const updated = toggleHabitCompletion(baseHabit, date);
    expect(updated.completions).toContain(date);
    expect(updated.completions).toHaveLength(1);
  });
  it('removes a completion date when the date already exists', () => {
    const date = '2024-01-10';
    const habit = { ...baseHabit, completions: [date] };
    const updated = toggleHabitCompletion(habit, date);
    expect(updated.completions).not.toContain(date);
    expect(updated.completions).toHaveLength(0);
  });
  it('does not mutate the original habit object', () => {
    const date = '2024-01-10';
    const originalCompletions = [...baseHabit.completions];
    toggleHabitCompletion(baseHabit, date);
    expect(baseHabit.completions).toEqual(originalCompletions);
  });
  it('does not return duplicate completion dates', () => {
    const date = '2024-01-10';
    const habit = { ...baseHabit, completions: [date, date] };
    const updated = toggleHabitCompletion(habit, date); // toggle removal, even if duplicates existed
    expect(updated.completions).toEqual([]);
  });
});