import sys
import xml.etree.ElementTree as ET
import datetime

def make_smooth(gpx_path, output_path, interval_seconds):
    # Register namespaces to preserve XML formatting
    ET.register_namespace('', 'http://www.topografix.com/GPX/1/1')
    
    try:
        tree = ET.parse(gpx_path)
    except Exception as e:
        print(f"❌ Error parsing {gpx_path}: {e}")
        sys.exit(1)
        
    root = tree.getroot()
    namespaces = {'gpx': 'http://www.topografix.com/GPX/1/1'}
    
    start_time = datetime.datetime(2026, 5, 28, 9, 0, 0, tzinfo=datetime.timezone.utc)
    count = 0
    
    for trkpt in root.findall('.//gpx:trkpt', namespaces):
        # Remove any existing time tags
        time_el = trkpt.find('gpx:time', namespaces)
        if time_el is not None:
            trkpt.remove(time_el)
            
        # Add new timestamp with custom interval
        new_time_el = ET.Element('{http://www.topografix.com/GPX/1/1}time')
        current_time = start_time + datetime.timedelta(seconds=count * interval_seconds)
        new_time_el.text = current_time.strftime('%Y-%m-%dT%H:%M:%SZ')
        trkpt.append(new_time_el)
        count += 1
        
    tree.write(output_path, encoding='utf-8', xml_declaration=True)
    print(f"✅ Successfully injected {count} smooth trackpoints (with {interval_seconds}s interval) into {output_path}!")

if __name__ == "__main__":
    interval = 1.0
    if len(sys.argv) > 1:
        try:
            interval = float(sys.argv[1])
        except ValueError:
            print("⚠️ Invalid interval argument. Using default of 1.0 seconds.")
            
    make_smooth('1.gpx', 'smooth_1.gpx', interval)
