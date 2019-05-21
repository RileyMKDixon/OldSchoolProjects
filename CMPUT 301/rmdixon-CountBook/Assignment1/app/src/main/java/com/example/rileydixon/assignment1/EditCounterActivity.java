/*
 * Copyright (c) 2017. Team rmdixon - CMPUT 301. University of Alberta - All rights reserved.
 * You may use, distribute, or modify this code under terms and conditions of the Code of Student Behaviour at University of Alberta.
 * You may find a copy of this licence in this project.  Otherwise please contact rmdixon@ualberta.ca.
 */

package com.example.rileydixon.assignment1;

import android.app.Activity;
import android.content.Intent;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

/**
 * The Activity responsible for allowing the user to modify a Counter.
 */
public class EditCounterActivity extends AppCompatActivity {

    private Counter workingCounter;
    private EditText editCounterNameText;
    private EditText editCounterCurrentValueText;
    private EditText editCounterInitialValueText;
    private EditText editCounterCommentText;

    public static final String EDIT_KEY = "com.example.rileydixon.assignment1.EDIT";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_counter);

        Intent editCounterIntent = getIntent();
        workingCounter = (Counter) editCounterIntent.getSerializableExtra(ViewingCounterActivity.VIEW_KEY);

        setTitle("Editing " + workingCounter.getCounterName());

        editCounterNameText = (EditText) findViewById(R.id.nameText);
        editCounterCurrentValueText = (EditText) findViewById(R.id.currentValueText);
        editCounterInitialValueText = (EditText) findViewById(R.id.initialValueText);
        editCounterCommentText = (EditText) findViewById(R.id.commentText);

        editCounterNameText.setText(workingCounter.getCounterName());
        editCounterCurrentValueText.setText(workingCounter.getCurrentValue().toString());
        editCounterInitialValueText.setText(workingCounter.getInitialValue().toString());
        editCounterCommentText.setText(workingCounter.getComment());

        Button editCancelButton = (Button) findViewById(R.id.cancelButton);
        editCancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.i("EditCounterActivity", "Edit Cancelled");
                setResult(Activity.RESULT_CANCELED);
                finish();
            }
        });
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem selection){ //For up button
        switch(selection.getItemId()){
            case android.R.id.home: //Up button pressed
                Log.i("EditCounterActivity", "Edit cancelled");
                setResult(Activity.RESULT_CANCELED);
                finish();
        }
        return true;
    }

    /**
     * Responsible for ensuring the user has entered in valid data into the Views.
     * Also ensures data consistency that a Counter is not left in a semi-valid state.
     *
     * @param doneEditCounterButton The button that is pressed when the user is done
     *                              editing the Counter.
     */
    public void doneEditCounterButton(View doneEditCounterButton){
        Counter dummyCounter; //The purpose of this counter is to hold pushing changes
                              //to the working counter until the data entered has been verified
        Intent editCounterIntent = new Intent();
        try {
            String editCounterName = editCounterNameText.getText().toString();
            String editCounterCurrentValue = editCounterCurrentValueText.getText().toString();
            String editCounterInitialValue = editCounterInitialValueText.getText().toString();
            String editCounterComment = editCounterCommentText.getText().toString();

            dummyCounter = new Counter(editCounterName, editCounterCurrentValue, editCounterInitialValue, editCounterComment);

            //If user has reached this point, then the data is valid
            //The reason why it looks redundant is such that we dont have a half baked Counter state
            //That is if the edited name clears but the edited counters do not, we dont want half
            //of the data valid and the other half not.
            workingCounter.setCounterName(dummyCounter.getCounterName());
            workingCounter.setCurrentValue(dummyCounter.getCurrentValue().toString());
            workingCounter.setInitialValue(dummyCounter.getInitialValue().toString());
            workingCounter.setComment(dummyCounter.getComment());
            workingCounter.setDateLastModified();

            editCounterIntent.putExtra(EDIT_KEY, workingCounter);
            setResult(Activity.RESULT_OK, editCounterIntent);
            finish();

        } catch (EmptyStringException ESE) {
            ESE.printStackTrace();
            AlertDialog.Builder eseDialogBuilder = new AlertDialog.Builder(this);
            eseDialogBuilder.setMessage("Counter Name and Initial Value cannot be empty.\nPlease enter in valid values for them.\n\nPress anywhere to continue.");
            eseDialogBuilder.setTitle("Cannot create counter");
            eseDialogBuilder.show();

        } catch (NegativeNumberException NNE) {
            NNE.printStackTrace();
            AlertDialog.Builder nneDialogBuilder = new AlertDialog.Builder(this);
            nneDialogBuilder.setMessage("Initial Value cannot be a negative number\n\nPress anywhere to continue.");
            nneDialogBuilder.setTitle("Cannot create counter");
            nneDialogBuilder.show();

        }
    }

}
