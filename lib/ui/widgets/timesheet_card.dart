import 'package:flutter/material.dart';
import '../../shared/app_sizer.dart';

class TimesheetCard extends StatelessWidget {
  final String visitId;
  final String clockIn;
  final String? clockOut;
  final String? duration;
  final VoidCallback onClockOut;
  final VoidCallback onExpandDetails;

  const TimesheetCard({
    super.key,
    required this.visitId,
    required this.clockIn,
    this.clockOut,
    this.duration,
    required this.onClockOut,
    required this.onExpandDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimension.getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '# $visitId',
                style: TextStyle(
                  fontSize: AppDimension.getFontSize(18),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF404969),
                ),
              ),
              if (clockOut == null)
                OutlinedButton(
                  onPressed: onClockOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimension.getWidth(16),
                      vertical: AppDimension.getHeight(8),
                    ),
                  ),
                  child: Text(
                    'Clock Out',
                    style: TextStyle(
                      fontSize: AppDimension.getFontSize(14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppDimension.getHeight(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Clock In: ',
                    style: TextStyle(
                      fontSize: AppDimension.getFontSize(16),
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    clockIn,
                    style: TextStyle(
                      fontSize: AppDimension.getFontSize(16),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF404969),
                    ),
                  ),
                ],
              ),
              if (clockOut != null && duration != null) ...[
                Row(
                  children: [
                    Text(
                      'Clock Out: ',
                      style: TextStyle(
                        fontSize: AppDimension.getFontSize(16),
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      clockOut!,
                      style: TextStyle(
                        fontSize: AppDimension.getFontSize(16),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF404969),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          if (clockOut != null && duration != null) ...[
            SizedBox(height: AppDimension.getHeight(4)),
            Row(
              children: [
                Text(
                  'Duration: ',
                  style: TextStyle(
                    fontSize: AppDimension.getFontSize(16),
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  duration!,
                  style: TextStyle(
                    fontSize: AppDimension.getFontSize(16),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF404969),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: AppDimension.getHeight(12)),
          InkWell(
            onTap: onExpandDetails,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimension.getWidth(16),
                vertical: AppDimension.getHeight(12),
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Appointment Details',
                    style: TextStyle(
                      fontSize: AppDimension.getFontSize(16),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF404969),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                    size: AppDimension.getWidth(24),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
