using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.IO;
using System.IO.Ports;
using System.Windows.Threading;
using System.Windows.Forms;
using System.Management;
using System.Runtime.InteropServices;
using System.ComponentModel;
using System.Diagnostics;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Timers;

namespace uart_display
{
    public class BrightnessControler
    {
        public ManagementScope scope;
        public ObjectQuery query;
        SelectQuery setQuery;
        public ManagementObjectSearcher searcher;
        bool PhysicalMonitoFlag = false;
        int initialPhysicalBrightness;

        List<ManagementObject> displayList;
        public BrightnessControler()
        {
            //laptop
            scope = new ManagementScope("\\\\.\\ROOT\\WMI");

            //create object query
            query = new ObjectQuery("SELECT * FROM WmiMonitorBrightness");
            setQuery = new SelectQuery("WmiMonitorBrightnessMethods");

            //create object searcher
            searcher = new ManagementObjectSearcher(scope, query);

            //get a collection of WMI objects
            //queryCollection = searcher.Get();

            displayList = new List<ManagementObject>();
            //enumerate the collection.

            using (searcher)
            {
                using (ManagementObjectCollection queryCollection = searcher.Get())
                {
                    foreach (ManagementObject m in queryCollection)
                    {
                        // access properties of the WMI object
                        displayList.Add(m);
                    }
                }
            }
        }

        public void setBrightness(int brightness)
        {
            try
            {
                using (ManagementObjectSearcher searcher = new ManagementObjectSearcher(scope, setQuery))
                {
                    using (ManagementObjectCollection objectCollection = searcher.Get())
                    {

                        foreach (ManagementObject mObj in objectCollection)
                        {
                            mObj.InvokeMethod("WmiSetBrightness",
                                new Object[] { UInt32.MaxValue, brightness });
                            break;
                        }

                    }
                }
            }
            catch
            {
                return;
            }
        }

        public void setInitialBrightness()
        {
            try
            {
                using (ManagementObjectSearcher searcher = new ManagementObjectSearcher(scope, setQuery))
                {
                    using (ManagementObjectCollection objectCollection = searcher.Get())
                    {
                        foreach (ManagementObject mObj in objectCollection)
                        {
                            mObj.InvokeMethod("WmiSetBrightness", new Object[] { UInt32.MaxValue, displayList[0]["CurrentBrightness"] });
                            break;
                        }
                    }
                }
            }
            catch
            {
                return;
            }
        }
    }
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {

        [DllImport("user32.dll")]
        public static extern IntPtr GetDC(IntPtr hWnd);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern int SendMessage(IntPtr hWnd, int wMsg, IntPtr wParam, IntPtr lParam);


        private static int total_gestures = 10;


        public uint[] FrameBuffer;
        
        byte[] sp_buffer;
        private WriteableBitmap smallBitmap;

        private ManagementEventWatcher watcher_add;
        private ManagementEventWatcher watcher_remove;

        SerialPort sp;

        bool en_sp_get = false;
        bool image_mode = false;

        string start_char = "j";
        private int file_idx;
        BrightnessControler brightnessControler;

        Dictionary<string, int> com_port_list;
        Stopwatch stopwatch;

        public MainWindow()
        {
            InitializeComponent();

            watcher_add = new ManagementEventWatcher();

            WqlEventQuery query_add = new WqlEventQuery("SELECT * FROM Win32_DeviceChangeEvent WHERE EventType = 2");
            watcher_add.EventArrived += new EventArrivedEventHandler(watcher_Event_add);
            watcher_add.Query = query_add;
            watcher_add.Start();

            watcher_remove = new ManagementEventWatcher();

            WqlEventQuery query_remove = new WqlEventQuery("SELECT * FROM Win32_DeviceChangeEvent WHERE EventType = 3");
            watcher_remove.EventArrived += new EventArrivedEventHandler(watcher_Event_remove);
            watcher_remove.Query = query_remove;
            watcher_remove.Start();

            sp = new SerialPort();
            stopwatch = new Stopwatch();
            sp.DataReceived += new SerialDataReceivedEventHandler(serialPortDataReceived);

            com_port_list = new Dictionary<string, int>();

            int port_num = 0;

            foreach (string s in System.IO.Ports.SerialPort.GetPortNames())
            {
                comboBoxUartPorts.Items.Add(s);
                com_port_list.Add(s, port_num++);
            }
            if(port_num > 0)
                comboBoxUartPorts.SelectedIndex = 0;
            comboBoxModes.Items.Add("None");
            comboBoxModes.Items.Add("Dimming");
            comboBoxModes.Items.Add("On Off");
            comboBoxModes.SelectedIndex = 0;

            FrameBuffer = new uint[32760];
            sp_buffer = new byte[65536];

            smallBitmap = new WriteableBitmap(32, 32, 96, 96, PixelFormats.Bgra32, null);
            labelResultIdx.IsEnabled = true;

            imageSmall.Source = smallBitmap;
            brightnessControler = new BrightnessControler();
            buttonSave32.IsEnabled = false;
        }

        private void spWrite()
        {
            try
            {
                sp.Write(start_char);
            }
            catch
            {
                stopUart();
                clearBuffer();
            }
        }

        public void SetGamma(int gesture_index)
        {
            if (stopwatch.ElapsedMilliseconds == 0)
                stopwatch.Start();
            else if (stopwatch.ElapsedMilliseconds < 500)
                return;
            else
                stopwatch.Stop();
            if (gesture_index == total_gestures+1)
            {
                this.brightnessControler.setInitialBrightness();
                return;
            }
            float brigtness = ((float)(gesture_index - 1) / (float)total_gestures) * 100;
            new Thread(() => this.brightnessControler.setBrightness((int)brigtness)).Start();
        }

        public void on_off_screen(int gesture_index)
        {
            if (stopwatch.ElapsedMilliseconds == 0)
                stopwatch.Start();
            else if (stopwatch.ElapsedMilliseconds < 500)
                return;
            else
                stopwatch.Stop();
            if (gesture_index < 0)
                return;
            if (gesture_index == 1)
            {
                try { 
                SendMessage(new Form().Handle, 0x112, (IntPtr)0xF170, (IntPtr)(2));
                System.Threading.Thread.Sleep(50);
                }
                catch
                {
                    return;
                }
            }
            else
            {
                try
                {
                    if(en_sp_get)
                        SendMessage(new Form().Handle, 0x112, (IntPtr)0xF170, (IntPtr)(-1));
                    System.Threading.Thread.Sleep(50);
                }
                catch
                {
                    return;
                }
            }
        }
        public void clearBuffer()
        {
            try
            {
                int count = sp.BytesToRead;
                byte[] temp_buffer = new byte[count];
                sp.Read(temp_buffer, 0, count);
                spWrite();
            }
            catch
            {
                stopUart();
            }
        }
        public void stopUart()
        {
            en_sp_get = false;
            this.Dispatcher.Invoke(DispatcherPriority.Normal, new Action(() => {
                checkBoxImage.IsEnabled = true;
                buttonUartGetGray.Content = "UART get";
            }));
            return;
        }

        private void serialPortDataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            int rd_size;
            int rd_total_size;
            byte r, g, b;

            int total_size;

            byte offset = 128;
            int result_idx = 0;

            if (en_sp_get ==true)
            {
               
                rd_total_size = 0;

                if (start_char == "j") // result
                {
                    total_size = 1;
                }
                else // result + image
                {
                    total_size = 1025;
                }
                offset = 0;

                try
                {
                    do
                    {
                        rd_size = sp.Read(sp_buffer, rd_total_size, 255);

                        rd_total_size += rd_size;

                    } while (rd_total_size < total_size);
                }
                catch
                {
                    clearBuffer();
                    return;
                }
                if (start_char == "k") // update images
                {
                    for (int y = 0; y < 32; y++)
                    {
                        for (int x = 0; x < 32; x++)
                        {
                            r = g = b = (byte)(sp_buffer[y * 32 + x] + offset);
                            FrameBuffer[y * 32 + x] = (uint)(0xff000000 + (r << 16) + (g << 8) + b);
                        }
                    }
                    result_idx = sp_buffer[1024] - 0x30;

                    if (result_idx < 0 || result_idx > total_gestures + 1)
                    {
                        en_sp_get = false;
                        clearBuffer();
                        Thread.Sleep(300);
                        en_sp_get = true;
                        return;
                    }
                }

                else if (start_char == "j") // class result
                {
                    result_idx = sp_buffer[0] - 0x30;
                }
                

                this.Dispatcher.Invoke(DispatcherPriority.Normal, new Action(() =>
                {
                    if (image_mode)
                        smallBitmap.WritePixels(new Int32Rect(0, 0, 32, 32), FrameBuffer, 32 * 4, 0);
                    else {
                        smallBitmap.WritePixels(new Int32Rect(0, 0, 32, 32), new uint[32760], 32* 4, 0); }
          
                    labelResultIdx.Content = String.Format("Predicted Class index = {0}", result_idx);
                    if (comboBoxModes.SelectedIndex == 1)
                        SetGamma(result_idx);
                    else if (comboBoxModes.SelectedIndex == 2)
                        on_off_screen(result_idx);

                }));
            }
            clearBuffer();
        }

        public void watcher_Event_add(object sender, EventArrivedEventArgs e)
        {

            this.Dispatcher.Invoke(DispatcherPriority.Normal, new Action(() =>
            {
                foreach (string s in System.IO.Ports.SerialPort.GetPortNames())
                {
                    // Check whether new one exist or not
                    if (com_port_list.ContainsKey(s) == false)
                    {
                        comboBoxUartPorts.Items.Add(s);
                        comboBoxUartPorts.SelectedIndex = comboBoxUartPorts.Items.Count - 1;
                        com_port_list.Add(s, comboBoxUartPorts.SelectedIndex);
                    }
                }
            }));

        }

        protected override void OnClosing(CancelEventArgs e)
        {
            en_sp_get = false;
            sp.DataReceived += closeapp;
            on_off_screen(11);
            brightnessControler.setInitialBrightness();
            base.OnClosing(e);
            System.Environment.Exit(0);
        }

        private void closeapp(object sender, SerialDataReceivedEventArgs e)
        {
            on_off_screen(11);
            brightnessControler.setInitialBrightness();
            base.OnClosing(new CancelEventArgs());
            System.Environment.Exit(0);
        }

        public void watcher_Event_remove(object sender, EventArrivedEventArgs e)
        {
            this.Dispatcher.Invoke(DispatcherPriority.Normal, new Action(() =>
            {
                // save current list and selected item
                string selected_port;
                if (comboBoxUartPorts.SelectedIndex >= 0)
                    selected_port = comboBoxUartPorts.Items[comboBoxUartPorts.SelectedIndex].ToString();
                else
                    selected_port = "";

                // Clear all dictionary and combobox
                comboBoxUartPorts.SelectedIndex = -1;
                com_port_list.Clear();
                comboBoxUartPorts.Items.Clear();

                int port_num = 0;
                foreach (string s in System.IO.Ports.SerialPort.GetPortNames())
                {
                    comboBoxUartPorts.Items.Add(s);
                    com_port_list.Add(s, port_num++);
                }

                // check whether previously selected port is still avaialble or not
                if (com_port_list.ContainsKey(selected_port) == true)
                {
                    comboBoxUartPorts.SelectedIndex = com_port_list[selected_port];
                }
                else
                {
                    // select first one
                    if (port_num > 0)
                        comboBoxUartPorts.SelectedIndex = 0;
                }
            }));

        }

        private void buttonSave32_Click(object sender, RoutedEventArgs e)
        {
            this.Dispatcher.Invoke(DispatcherPriority.Normal, new Action(() =>
            {
                saveImage(textBoxFolder.Text + "\\" + textBoxPrefix.Text + file_idx.ToString() + ".png");
                file_idx++;
            }));
        }


        private void buttonUartGetGray_Click(object sender, RoutedEventArgs e)
        {
            if (en_sp_get == false)
            {
                try
                {

                    if (!sp.IsOpen)
                    {
                        sp.PortName = comboBoxUartPorts.Items[comboBoxUartPorts.SelectedIndex].ToString();
                        sp.BaudRate = 230400;
                        sp.Parity = Parity.None;
                        sp.DataBits = 8;
                        sp.StopBits = StopBits.One;

                        sp.ReadTimeout = 500;
                        sp.Open();
                    }
                    
                    en_sp_get = true;
                    buttonUartGetGray.Content = "Stop Uart";
                    checkBoxImage.IsEnabled = false;
                    spWrite();
                }
                catch (Exception exeption)
                {
                    stopUart();
                }
            }
            else
            {
                stopUart();
            }
        }
        
        private void saveImage(string FileName, int size = 32)
        {
            System.Drawing.Bitmap save_bitmap;

            int p, r, g, b;

            save_bitmap = new System.Drawing.Bitmap(size, size);

            for (int y = 0; y < size; y++)
            {
                for (int x = 0; x < size; x++)
                {

                    p = (int)FrameBuffer[y * size + x];
                    r = (p >> 16) & 0xff;
                    g = (p >> 8) & 0xff;
                    b = (p) & 0xff;

                    save_bitmap.SetPixel(x, y, System.Drawing.Color.FromArgb(r, g, b));

                }
            }
            save_bitmap.Save(FileName);
        }

        private void checkBoxImage_Click(object sender, RoutedEventArgs e)
        {
            image_mode = (checkBoxImage.IsChecked == true);
            if (image_mode == false)
            {
                checkBoxSaveImages.IsChecked = false;
                buttonSave32.IsEnabled = false;
                start_char = "j";
            }
            else {
                start_char = "k";
            }
        }

        private void buttonSelectFolder_Click(object sender, RoutedEventArgs e)
        {
            var folderBrowseDialog = new FolderBrowserDialog();
            folderBrowseDialog.SelectedPath = textBoxFolder.Text;

            var result = folderBrowseDialog.ShowDialog();

            if (result == System.Windows.Forms.DialogResult.OK)
            {
                textBoxFolder.Text = folderBrowseDialog.SelectedPath;

            }
        }

        private void checkBoxSaveImages_Checked(object sender, RoutedEventArgs e)
        {
            if (checkBoxSaveImages.IsChecked == true)
            {
                checkBoxImage.IsChecked = true;
                buttonSave32.IsEnabled = true;
                start_char = "k";
                file_idx = 1;
            }
            else {
                buttonSave32.IsEnabled = false;
             }
        }

    }
}
