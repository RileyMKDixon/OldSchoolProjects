/*
 * Copyright (c) 2017. Team rmdixon - CMPUT 301. University of Alberta - All rights reserved.
 * You may use, distribute, or modify this code under terms and conditions of the Code of Student Behaviour at University of Alberta.
 * You may find a copy of this licence in this project.  Otherwise please contact rmdixon@ualberta.ca.
 */

package com.example.rileydixon.assignment1;

import android.app.Activity;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

/**
 * The activity responsible for showing the details of a counter when selected from the
 * main activity.
 * The user may quickly increment or decrement the counter as well as resenting the current value
 * back to the initial value. Additionally they can edit the Counter's data fields or delete the
 * Counter entirely.
 */
public class ViewingCounterActivity extends AppCompatActivity {

    private Counter workingCounter;
    private int position;
    private TextView counterText;
    private TextView commentText;

    public static final String VIEW_KEY = "com.example.rileydixon.assignment1.VIEW";
    public static final String VIEW_KEY_POSITION = "com.example.rileydixon.assignment1.VIEW_POSITION";
    public static final int EDIT_COUNTER = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_viewing_counter);

        counterText = (TextView)findViewById(R.id.counterText);
        commentText = (TextView)findViewById(R.id.commentText);
        Button incrementButton = (Button)findViewById(R.id.incrementButton);
        Button decrementButton = (Button)findViewById(R.id.decrementButton);
        Button editButton = (Button)findViewById(R.id.editButton);
        Button resetButton = (Button)findViewById(R.id.resetButton);
        Button deleteButton = (Button)findViewById(R.id.deleteButton);

        Intent viewCounterIntent = getIntent();
        workingCounter = (Counter) viewCounterIntent.getSerializableExtra(VIEW_KEY);
        position = viewCounterIntent.getIntExtra(VIEW_KEY_POSITION, -1);
        //Note, if the position cant be found for whatever reason, -1 WILL cause
        //a runtime exception when trying to read/write the ArrayList in main.
        //This is desired.
        //Alternatively we could call an exception here and exit the Activity (viewing counter)

        counterText.setText(workingCounter.getCurrentValue().toString());
        commentText.setText(workingCounter.getComment());
        setTitle(workingCounter.getCounterName());


        incrementButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                workingCounter.incrementCounter();
                counterText.setText(workingCounter.getCurrentValue().toString());
            }
        });

        decrementButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                workingCounter.decrementCounter();
                counterText.setText(workingCounter.getCurrentValue().toString());

            }
        });

        editButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent editWorkingCounter = new Intent(ViewingCounterActivity.this, EditCounterActivity.class);
                editWorkingCounter.putExtra(VIEW_KEY, workingCounter);
                startActivityForResult(editWorkingCounter, EDIT_COUNTER);
            }
        });

        resetButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                workingCounter.resetCounter();
                workingCounter.setDateLastModified();
                counterText.setText(workingCounter.getCurrentValue().toString());
            }
        });

        deleteButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent counterToBeDeleted = new Intent();
                counterToBeDeleted.putExtra(VIEW_KEY_POSITION, position);
                setResult(Activity.RESULT_CANCELED, counterToBeDeleted);
                finish();
            }
        });
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem selection){
        switch(selection.getItemId()){
            case android.R.id.home: //Up button pressed
                Log.i("ViewingCounterActivity", "Back Button Pressed. Save Changes");

                Intent sendModifiedCounter = new Intent();
                sendModifiedCounter.putExtra(VIEW_KEY, workingCounter);
                sendModifiedCounter.putExtra(VIEW_KEY_POSITION, position);
                setResult(Activity.RESULT_OK, sendModifiedCounter);
                finish();
        }
        return true;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent modifiedCounterIntent){
        if(requestCode == EDIT_COUNTER){
            if(resultCode == Activity.RESULT_OK){
                //Refresh the Text Views
                workingCounter = (Counter) modifiedCounterIntent.getSerializableExtra(EditCounterActivity.EDIT_KEY);

                setTitle(workingCounter.getCounterName());
                counterText.setText(workingCounter.getCurrentValue().toString());
                commentText.setText(workingCounter.getComment());
                Log.i("ViewingCounterActivity", "Edit Complete");
            }else if(resultCode == Activity.RESULT_CANCELED){
                Log.i("ViewingCounterActivity", "Edit Cancelled");
            }
        }
    }
}
