using System;
using UnityEngine;  
using UnityEngine.UI; // 引入UI命名空间  
  
public class SpeedController : MonoBehaviour  
{  
    public Text speedText; // 引用UI Text组件  
    private float speed = 0f; // 当前速度  
    private float speedChangeRate = 10f; // 加速/减速率  
    private float decelerationRate; // 减速率（可以是加速率的一半）  

    private void Start()
    {;
        decelerationRate = speedChangeRate * 0.5f;
    }

    void Update()  
    {  
        // 检查W键是否被按下  
        if (Input.GetKey(KeyCode.W) && !Input.GetKey(KeyCode.S)) // 确保S键没有被同时按下  
        {  
            // 增加速度，但不超过120  
            speed = Mathf.Min(speed + speedChangeRate * Time.deltaTime, 120f);  
        }  
  
        // 检查S键是否被按下，或者既没有按W也没有按S但之前是按下的（模拟松开W后的减速）  
        if (Input.GetKey(KeyCode.S) || (!Input.GetKey(KeyCode.W) && speed > 0f))  
        {  
            // 减少速度，但不低于0  
            speed = Mathf.Max(speed - (Input.GetKey(KeyCode.S) ? speedChangeRate : decelerationRate) * Time.deltaTime, 0f);  
        }  
  
        // 更新UI显示的速度（四舍五入为整数）  
        speedText.text = "Speed: " + Mathf.RoundToInt(speed).ToString() + " km/h";  
    }  
}