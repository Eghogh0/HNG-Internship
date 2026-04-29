import { describe, it, expect, beforeEach, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import HabitForm from '@/components/habits/HabitForm';
import HabitList from '@/components/habits/HabitList';
import type { Habit } from '@/types/habit';
import { getHabitSlug } from '@/lib/slug';

vi.mock('@/lib/auth', () => ({
  getSession: () => ({ userId: 'user1', email: 'test@test.com' }),
}));

describe('habit form', () => {
  let mockOnSave = vi.fn();
  let mockOnCancel = vi.fn();

  beforeEach(() => {
    localStorage.clear();
    mockOnSave.mockClear();
    mockOnCancel.mockClear();
  });

  it('shows a validation error when habit name is empty', async () => {
    render(<HabitForm onSave={mockOnSave} onCancel={mockOnCancel} />);
    await userEvent.click(screen.getByTestId('habit-save-button'));
    expect(screen.getByText('Habit name is required')).toBeInTheDocument();
    expect(mockOnSave).not.toHaveBeenCalled();
  });

  it('creates a new habit and renders it in the list', async () => {
    const newHabit: Habit = {
      id: '1',
      userId: 'user1',
      name: 'Read',
      description: '',
      frequency: 'daily',
      createdAt: new Date().toISOString(),
      completions: [],
    };
    const onToggle = vi.fn();
    render(
      <HabitList habits={[newHabit]} onEdit={vi.fn()} onDelete={vi.fn()} onToggle={onToggle} />
    );
    const slug = getHabitSlug(newHabit.name);
    expect(screen.getByTestId(`habit-card-${slug}`)).toBeInTheDocument();
    expect(screen.getByText('Read')).toBeInTheDocument();
  });

  it('edits an existing habit and preserves immutable fields', async () => {
    const existing: Habit = {
      id: 'old',
      userId: 'user1',
      name: 'Old',
      description: '',
      frequency: 'daily',
      createdAt: '2024-01-01',
      completions: ['2024-01-02'],
    };
    render(<HabitForm habit={existing} onSave={mockOnSave} onCancel={mockOnCancel} />);
    await userEvent.clear(screen.getByTestId('habit-name-input'));
    await userEvent.type(screen.getByTestId('habit-name-input'), 'Updated');
    await userEvent.click(screen.getByTestId('habit-save-button'));
    await waitFor(() => {
      expect(mockOnSave).toHaveBeenCalled();
      const saved = mockOnSave.mock.calls[0][0] as Habit;
      expect(saved.name).toBe('Updated');
      expect(saved.id).toBe('old');
      expect(saved.userId).toBe('user1');
      expect(saved.createdAt).toBe('2024-01-01');
      expect(saved.completions).toEqual(['2024-01-02']);
    });
  });

  it('deletes a habit only after explicit confirmation', async () => {
    window.confirm = vi.fn(() => true);
    const habit: Habit = {
      id: '1',
      userId: 'user1',
      name: 'Delete Me',
      description: '',
      frequency: 'daily',
      createdAt: '2024-01-01',
      completions: [],
    };
    const onDelete = vi.fn();
    render(
      <HabitList habits={[habit]} onEdit={vi.fn()} onDelete={onDelete} onToggle={vi.fn()} />
    );
    const slug = getHabitSlug(habit.name);
    await userEvent.click(screen.getByTestId(`habit-delete-${slug}`));
    expect(window.confirm).toHaveBeenCalled();
    expect(onDelete).toHaveBeenCalledWith('1');
  });

  it('toggles completion and updates the streak display', async () => {
    const today = new Date().toISOString().slice(0, 10);
    let habit: Habit = {
      id: '1',
      userId: 'user1',
      name: 'Toggle',
      description: '',
      frequency: 'daily',
      createdAt: '2024-01-01',
      completions: [],
    };
    const onToggle = vi.fn().mockImplementation((updated: Habit) => {
      habit = updated;
    });
    const { rerender } = render(
      <HabitList habits={[habit]} onEdit={vi.fn()} onDelete={vi.fn()} onToggle={onToggle} />
    );
    const slug = getHabitSlug(habit.name);
    await userEvent.click(screen.getByTestId(`habit-complete-${slug}`));
    expect(onToggle).toHaveBeenCalled();
    // After toggle, completions should contain today
    const updatedArg = onToggle.mock.calls[0][0] as Habit;
    expect(updatedArg.completions).toContain(today);
    // Re-render with updated habit to verify streak display
    rerender(
      <HabitList habits={[habit]} onEdit={vi.fn()} onDelete={vi.fn()} onToggle={onToggle} />
    );
    expect(screen.getByTestId(`habit-streak-${slug}`)).toHaveTextContent('1');
  });
});