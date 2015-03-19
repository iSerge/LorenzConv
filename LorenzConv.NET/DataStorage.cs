using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace LorenzConv.NET
{
	public class DataStorage: INotifyPropertyChanged
	{
		public event PropertyChangedEventHandler PropertyChanged;

		float _gamma = 2.0f;
		public float Gamma {
			get {return _gamma; }
			set {
				if (_gamma == value) return;
				_gamma = value;
				Console.WriteLine("Gamma updated to: {0}", value);
				NotifyPropertyChanged("Gamma");
			}
		}

		//private void NotifyPropertyChanged([CallerMemberName] String propertyName = "")
		private void NotifyPropertyChanged(String propertyName)
		{
			if (PropertyChanged != null){
				PropertyChanged(this, new PropertyChangedEventArgs(propertyName));
			}
		}
	}
}

