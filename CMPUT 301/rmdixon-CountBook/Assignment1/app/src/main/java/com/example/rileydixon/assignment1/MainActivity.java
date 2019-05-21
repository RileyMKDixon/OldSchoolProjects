/*
 * Copyright (c) 2017. Team rmdixon - CMPUT 301. University of Alberta - All rights reserved.
 * You may use, distribute, or modify this code under terms and conditions of the Code of Student Behaviour at University of Alberta.
 * You may find a copy of this licence in this project.  Otherwise please contact rmdixon@ualberta.ca.
 */

package com.example.rileydixon.assignment1;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.lang.reflect.Type;
import java.util.ArrayList;

/**
 * The starting activity for our android app. Contains a list of all current counters present.
 */
public class MainActivity extends AppCompatActivity {

    public static final String MAIN_KEY = "com.example.rileydixon.assignment1.MAIN";
    private static final String FILENAME = "counts.sav";
    private static final int ADD_ACTIVITY = 1;
    private static final int VIEW_ACTIVITY = 2;

    private ListView countList;
    private ArrayList<Counter> counterArrayList;
    private ArrayAdapter<Counter> adapter;

    @Override
    protected void onStart(){
        super.onStart();
        loadCounters();
        adapter = new ArrayAdapter<Counter>(this, R.layout.list_layout, counterArrayList);
        countList.setAdapter(adapter);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        countList = (ListView) findViewById(R.id.countList);

        countList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int position, long id) {
                Counter viewCounter = counterArrayList.get(position);
                Intent viewCounterActivity = new Intent(MainActivity.this, ViewingCounterActivity.class);
                viewCounterActivity.putExtra(ViewingCounterActivity.VIEW_KEY, viewCounter);
                viewCounterActivity.putExtra(ViewingCounterActivity.VIEW_KEY_POSITION, position);
                startActivityForResult(viewCounterActivity, VIEW_ACTIVITY);
            }
        });
    }

    /**
     * Creates a new counter in the app.
     *
     * @param newCounterButtonView The button that when pressed directs the user to a new activity
     *                             AddCounterActivity and directs the user through the steps to
     *                             constructing a new counter.
     * @see AddCounterActivity
     */
    public void addNewCounter(View newCounterButtonView){
        Intent newCounterActivity = new Intent(this, AddCounterActivity.class);
        startActivityForResult(newCounterActivity, ADD_ACTIVITY);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent receivedCounter){
        if(requestCode == ADD_ACTIVITY){
            if(resultCode == Activity.RESULT_OK){
                Counter newCounter = (Counter) receivedCounter.getSerializableExtra(AddCounterActivity.ADD_KEY);
                counterArrayList.add(newCounter);
                adapter.notifyDataSetChanged();
                saveCounters();
            }else if(resultCode == Activity.RESULT_CANCELED){
                Log.d("User Cancelled", "Back Button pressed");
            }
        }else if(requestCode == VIEW_ACTIVITY){
            if(resultCode == Activity.RESULT_OK){
                Counter viewedCounter = (Counter) receivedCounter.getSerializableExtra(ViewingCounterActivity.VIEW_KEY);
                int position = receivedCounter.getIntExtra(ViewingCounterActivity.VIEW_KEY_POSITION, -1);
                counterArrayList.set(position, viewedCounter);
                saveCounters();
            }else if(resultCode == Activity.RESULT_CANCELED){
                //Counter deleteCounter = (Counter) receivedCounter.getSerializableExtra(ViewingCounterActivity.VIEW_KEY);
                int position = receivedCounter.getIntExtra(ViewingCounterActivity.VIEW_KEY_POSITION, -1);
                counterArrayList.remove(position);
                adapter.notifyDataSetChanged();
                saveCounters();
            }
        }
    }

    //Credit to CMPUT301 LABTA: https://github.com/ta301fall2017/lonelyTwitter/tree/f17TueLab3
    //For the saving and loading code.
    //2017-09-19
    private void loadCounters() {
        try {
            FileInputStream fis = openFileInput(FILENAME);
            BufferedReader in = new BufferedReader(new InputStreamReader(fis));

            Gson gson = new Gson();

            //Taken from https://stackoverflow.com/questions/12384064/gson-convert-from-json-to-a-typed-arraylistt
            // 2017-09-19
            Type listType = new TypeToken<ArrayList<Counter>>(){}.getType();
            counterArrayList = gson.fromJson(in, listType);

        } catch (FileNotFoundException e) {
            // TODO Auto-generated catch block
            counterArrayList = new ArrayList<Counter>();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            throw new RuntimeException();
        }

    }

    private void saveCounters() {
        try {
            FileOutputStream fos = openFileOutput(FILENAME,
                    Context.MODE_PRIVATE);

            BufferedWriter out = new BufferedWriter(new OutputStreamWriter(fos));

            Gson gson = new Gson();
            gson.toJson(counterArrayList, out);
            out.flush();

            fos.close();
        } catch (FileNotFoundException e) {
            // TODO Auto-generated catch block
            throw new RuntimeException();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            throw new RuntimeException();
        }
    }

}
