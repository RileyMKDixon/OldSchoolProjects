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
import android.view.View;
import android.widget.EditText;

/**
 * This activity is responsible for directing the user through the steps
 * to create a new Counter.
 */
public class AddCounterActivity extends AppCompatActivity {

    public static final String ADD_KEY = "com.examples.rileydixon.assignment1.ADD";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_counter);
    }

    /**
     * Ensures that the data entered is valid before packaging it up in an intent
     * and returning the Counter to the MainActivity.
     *
     * @param doneNewCounterButton The button responsible for detecting when a user
     *                             is done entering in data.
     */
    public void returnNewCounter(View doneNewCounterButton){
        Intent createCounterIntent = new Intent();
        try {
            String counterName = ((EditText) findViewById(R.id.nameText)).getText().toString();
            String counterComment = ((EditText) findViewById(R.id.commentText)).getText().toString();
            String counterInitialValueStr = ((EditText) findViewById(R.id.initialValueText)).getText().toString();

            Counter newCounter = new Counter(counterName, counterInitialValueStr, counterComment);
            //If user has reached this point, then the data is valid
            createCounterIntent.putExtra(ADD_KEY, newCounter);
            setResult(Activity.RESULT_OK, createCounterIntent);
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
