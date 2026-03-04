# To-Do List App: Product Backlog

## Product Goal
> "To build a fast, intuitive, and reliable mobile application that empowers users to capture, organize, and track their daily tasks efficiently, ensuring no important commitment is overlooked."

---

## User Stories

### User Story #1: Create a New Task
**Description:**
*As a* user,
*I want to* add a new task to my list,
*So that* I can record what I need to do before I forget it.

**Acceptance Criteria:**
* **Scenario 1: Successful task creation**
  * **Given** the user is on the main screen,
  * **When** they tap the "Add Task" (+) button,
  * **Then** a text input field should be displayed.
* **Scenario 2: Saving the task**
  * **Given** the text input field is active,
  * **When** the user types a description and taps "Save",
  * **Then** the new task must be added to the top of the To-Do list.
* **Scenario 3: Empty task prevention**
  * **Given** the text input field is empty,
  * **When** the user attempts to tap "Save",
  * **Then** the action must be prevented and a subtle warning should indicate that a task needs text.

---

### User Story #2: Mark a Task as Completed
**Description:**
*As a* user,
*I want to* mark a task as completed,
*So that* I can track my progress, feel a sense of accomplishment, and focus only on pending items.

**Acceptance Criteria:**
* **Scenario 1: Marking as done**
  * **Given** an active task is displayed on the list,
  * **When** the user taps the checkbox (or completion icon) next to it,
  * **Then** the task's status must change to "completed" in the system.
* **Scenario 2: Visual feedback**
  * **Given** a task has been marked as completed,
  * **When** it is displayed on the screen,
  * **Then** it must have a clear visual indicator (e.g., a strikethrough text style) to differentiate it from pending tasks.
* **Scenario 3: Reverting completion (Undo)**
  * **Given** a task is currently marked as completed,
  * **When** the user taps the checkbox again,
  * **Then** the task must revert to an "active" state and the visual completion indicator must be removed.

---

### User Story #3: Delete an Existing Task
**Description:**
*As a* user,
*I want to* delete a task from my list,
*So that* I can keep my workspace clean, remove mistakes, and discard items I no longer plan to do.

**Acceptance Criteria:**
* **Scenario 1: Triggering the deletion**
  * **Given** the user is viewing their list of tasks,
  * **When** they swipe left on a specific task (or tap the trash can icon),
  * **Then** the task must be immediately removed from the visible list.
* **Scenario 2: Data removal**
  * **Given** a task has been removed from the UI,
  * **When** the system processes the deletion,
  * **Then** the task record must be permanently deleted from the local database.
* **Scenario 3: Grace period (Undo action)**
  * **Given** the user has just swiped to delete a task,
  * **When** the task disappears,
  * **Then** a temporary message (Snackbar) must appear at the bottom of the screen offering an "Undo" button.
* **Scenario 4: Recovering a deleted task**
  * **Given** the deletion Snackbar is active,
  * **When** the user taps "Undo",
  * **Then** the deletion process is canceled, and the task must reappear in its original position in the list.

---

### User Story #4: Edit an Existing Task
**Description:**
*As a* user,
*I want to* modify the text of a task I already created,
*So that* I can fix typos, add more details, or update my objective without having to delete and recreate the entire item.

**Acceptance Criteria:**
* **Scenario 1: Entering edit mode**
  * **Given** the user is viewing their task list,
  * **When** they tap on the text of a specific task,
  * **Then** the task text must transform into an active text input field, pre-filled with the current description.
* **Scenario 2: Saving the modification**
  * **Given** the user is in edit mode and has changed the text,
  * **When** they tap "Save" or the keyboard's "Done" button,
  * **Then** the task must be updated in the database and the list should reflect the new text.
* **Scenario 3: Canceling an edit**
  * **Given** the user is in edit mode modifying a task,
  * **When** they tap outside the input field or press a "Cancel" button,
  * **Then** the edit mode must close, and the task must revert to its original text.
* **Scenario 4: Preventing empty edits**
  * **Given** the user deletes all text while in edit mode,
  * **When** they attempt to save,
  * **Then** the system must prevent the save with a warning.
